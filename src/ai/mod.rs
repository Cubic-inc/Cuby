use std::time::SystemTime;

use ollama_rs::generation::chat::{ChatMessage, request::ChatMessageRequest};
use serde::Serialize;
use twilight_model::channel::Message;

use crate::{State, extensions::message::MessageExt};

mod tools;

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

pub async fn handle_incoming_message(state: State, message: &Message) {
    let current_user = state.discord_cache.current_user().unwrap();

    if !message.mentions_user(current_user.id) {
        return;
    }

    if message.author.bot {
        return;
    }

    let model = state.ollama_model;
    let ollama = state.ollama_client;

    let _ = state
        .discord_http
        .create_typing_trigger(message.channel_id)
        .await;

    let system_message = ChatMessage::system(include_str!("./system.md").into());
    let user_info_message = ChatMessage::system(format!("Your user id is: {}", current_user.id));

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

    let mut messages = vec![system_message, user_info_message];

    for message in &context_messages {
        if message.author.id == current_user.id {
            messages.push(ChatMessage::assistant(message.content.clone()));
        } else {
            messages.push(ChatMessage::user(InputMessage::from(message).into()));
        }
    }

    messages.push(ChatMessage::user(InputMessage::from(message).into()));

    tracing::info!("Sending messages to Ollama: {:#?}", messages);

    let request = ChatMessageRequest::new(model, messages);
    let response = ollama.send_chat_messages(request).await.unwrap();

    tracing::info!("Received response from Ollama: {:#?}", response);

    let _ = state
        .discord_http
        .create_message(message.channel_id)
        .content(&response.message.content)
        .reply(message.id)
        .await;
}
