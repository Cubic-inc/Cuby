use std::time::SystemTime;

use ollama_rs::generation::{
    chat::{ChatMessage, request::ChatMessageRequest},
    parameters::{FormatType, JsonStructure},
};
use ollama_rs::re_exports::schemars::json_schema;
use serde::{Deserialize, Serialize};
use twilight_model::channel::Message;

use crate::{State, extensions::message::MessageExt};

mod tools;

#[derive(Debug, Deserialize)]
struct OutputMessage {
    content: String,
}

#[derive(Debug, Clone, Serialize)]
struct InputMessage {
    message_id: String,
    replying_to_id: Option<String>,
    user_id: String,
    user_name: String,
    content: String,
    posted_at: String,
}

impl From<&Message> for InputMessage {
    fn from(message: &Message) -> Self {
        let posted_at = {
            let now = SystemTime::now()
                .duration_since(SystemTime::UNIX_EPOCH)
                .unwrap()
                .as_secs();
            let diff = now.saturating_sub(message.timestamp.as_secs() as u64);
            match diff {
                0..=59 => "less than 1 minute ago".to_string(),
                60..=3599 => {
                    let mins = diff / 60;
                    format!("{} minute{} ago", mins, if mins == 1 { "" } else { "s" })
                }
                3600..=86399 => {
                    let hours = diff / 3600;
                    format!("{} hour{} ago", hours, if hours == 1 { "" } else { "s" })
                }
                _ => {
                    let days = diff / 86400;
                    format!("{} day{} ago", days, if days == 1 { "" } else { "s" })
                }
            }
        };

        Self {
            message_id: message.id.to_string(),
            replying_to_id: message
                .referenced_message
                .as_ref()
                .map(|m| m.id.to_string()),
            user_id: message.author.id.to_string(),
            user_name: message
                .author
                .global_name
                .clone()
                .unwrap_or(message.author.name.clone()),
            content: message.content.clone(),
            posted_at,
        }
    }
}

impl Into<String> for InputMessage {
    fn into(self) -> String {
        serde_json::to_string_pretty(&self).unwrap_or_else(|_| "{}".to_string())
    }
}

pub async fn handle_incoming_message(state: State, discord_message: &Message) {
    let current_user = state.discord_cache.current_user().unwrap();

    if !discord_message.mentions_user(current_user.id) {
        return;
    }

    if discord_message.author.bot {
        return;
    }

    let model = state.ollama_model.clone();
    let ollama = state.ollama_client.clone();

    let _ = state
        .discord_http
        .create_typing_trigger(discord_message.channel_id)
        .await;

    let tools = tools::get_tools();
    let system_message = ChatMessage::system(include_str!("./system.md").into());
    let user_info_message = ChatMessage::system(format!("Your user id is: {}", current_user.id));

    // Fetch previous messages from the channel for conversation context
    let context_messages = match state
        .discord_http
        .channel_messages(discord_message.channel_id)
        .before(discord_message.id)
        .limit(25u16)
        .await
    {
        Ok(response) => match response.model().await {
            Ok(msgs) => {
                // Messages come in reverse chronological order; reverse to get chronological order
                let mut sorted = msgs;
                sorted.reverse();
                sorted
            }
            Err(e) => {
                tracing::warn!("Failed to deserialize channel messages: {:?}", e);
                Vec::new()
            }
        },
        Err(e) => {
            tracing::warn!("Failed to fetch channel messages: {:?}", e);
            Vec::new()
        }
    };

    let mut messages = vec![system_message, user_info_message];

    for msg in &context_messages {
        let input_message = InputMessage::from(msg);
        if msg.author.id == current_user.id {
            messages.push(ChatMessage::assistant(input_message.into()));
        } else {
            messages.push(ChatMessage::user(input_message.into()));
        }
    }

    messages.push(ChatMessage::user(
        InputMessage::from(discord_message).into(),
    ));

    tracing::info!("Sending messages to Ollama: {:#?}", messages);

    let mut executed_tools: Vec<(String, serde_json::Value)> = Vec::new();

    let response = loop {
        let request = ChatMessageRequest::new(model.clone(), messages.clone())
            .tools(tools.iter().map(|tool| tool.info()).collect())
            .format(FormatType::StructuredJson(Box::new(
                JsonStructure::new_for_schema(json_schema!({
                    "type": "object",
                    "properties": {
                        "content": {
                            "type": "string",
                            "description": "The response message content"
                        }
                    },
                    "required": ["content"]
                })),
            )));

        let response = ollama.send_chat_messages(request).await.unwrap();
        let ai_message = &response.message;

        if ai_message.tool_calls.is_empty() {
            break response;
        } else {
            messages.push(ai_message.clone());

            for tool_call in &ai_message.tool_calls {
                let tool_name = &tool_call.function.name;
                let arguments = &tool_call.function.arguments;

                let result = match tools
                    .iter()
                    .find(|tool| tool.info().function.name == *tool_name)
                {
                    Some(tool) => {
                        let result = tool.execute(state.clone(), arguments.clone()).await;
                        executed_tools.push((tool_name.clone(), arguments.clone()));
                        result
                    }
                    None => format!("Tool '{}' not found", tool_name),
                };

                messages.push(ChatMessage::tool(result));
            }
        }
    };

    tracing::info!("Received response from Ollama: {:#?}", response);

    // Workaround to stop the model responding in json
    let content = serde_json::from_str::<OutputMessage>(&response.message.content)
        .map(|o| o.content)
        .unwrap_or(response.message.content);

    let result = state
        .discord_http
        .create_message(discord_message.channel_id)
        .content(&content)
        .reply(discord_message.id)
        .await;

    match result {
        Ok(response_msg) => {
            let response_message = response_msg.model().await.ok();
            if let Some(response_message) = &response_message {
                for (tool_name, arguments) in &executed_tools {
                    if let Some(tool) = tools.iter().find(|t| t.info().function.name == *tool_name)
                    {
                        tool.post_execute(state.clone(), response_message, arguments.clone())
                            .await;
                    }
                }
            }
        }
        Err(e) => {
            tracing::error!("Failed to create response message: {:?}", e);
        }
    }
}
