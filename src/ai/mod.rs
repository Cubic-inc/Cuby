use futures_util::StreamExt;
use ollama_rs::generation::chat::{ChatMessage, request::ChatMessageRequest};
use serde::Serialize;
use twilight_model::channel::Message;

use crate::{State, extensions::message::MessageExt};

#[derive(Debug, Clone, Serialize)]
struct InputMessage {
    message_id: String,
    replying_to_id: Option<String>,
    user_id: String,
    user_name: String,
    content: String,
}

impl From<&Message> for InputMessage {
    fn from(message: &Message) -> Self {
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
        }
    }
}

impl Into<String> for InputMessage {
    fn into(self) -> String {
        serde_json::to_string_pretty(&self).unwrap_or_else(|_| "{}".to_string())
    }
}

pub async fn handle_incoming_message(state: State, message: &Message) {
    println!("{:#?}", message);
    if message.author.bot {
        return;
    }

    if !message.mentions_user(state.discord_cache.current_user().unwrap().id) {
        return;
    }

    let model = state.ollama_model;
    let ollama = state.ollama_client;

    let _ = state
        .discord_http
        .create_typing_trigger(message.channel_id)
        .await;

    let system_message = ChatMessage::system(include_str!("./system.md").into());

    // Fetch previous messages from the channel for conversation context
    let context_messages = match state
        .discord_http
        .channel_messages(message.channel_id)
        .before(message.id)
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

    let mut messages = vec![system_message];

    for message in &context_messages {
        if message.author.bot {
            messages.push(ChatMessage::assistant(message.content.clone()));
        } else {
            messages.push(ChatMessage::user(InputMessage::from(message).into()));
        }
    }

    messages.push(ChatMessage::user(InputMessage::from(message).into()));

    tracing::info!("Sending messages to Ollama: {:#?}", messages);

    let request = ChatMessageRequest::new(model, messages);
    let mut stream = ollama.send_chat_messages_stream(request).await.unwrap();

    let mut content = String::new();

    while let Some(response) = stream.next().await {
        match response {
            Ok(chat_response) => {
                tracing::info!("AI Response: {:#?}", chat_response);
                content.push_str(&chat_response.message.content);
            }
            Err(e) => {
                tracing::error!("Error receiving AI response: {:?}", e);
            }
        }
    }

    let _ = state
        .discord_http
        .create_message(message.channel_id)
        .content(&content)
        .reply(message.id)
        .await;
}
