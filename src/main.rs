use std::{error::Error, sync::Arc};

use ollama_rs::Ollama;
use reqwest::header::HeaderMap;
use rusqlite::Connection;
use tokio::sync::Mutex;
use twilight_cache_inmemory::{DefaultInMemoryCache, ResourceType};
use twilight_gateway::{Event, EventTypeFlags, Intents, Shard, ShardId, StreamExt as _};
use twilight_http::Client as HttpClient;

use crate::{
    database::Migration,
    interactions::InteractionHandlers,
    reminder::{RemindLocation, ReminderManager},
};

mod ai;
mod database;
pub mod extensions;
mod interactions;
mod reminder;
pub mod utility;

#[derive(Clone)]
struct State {
    ollama_model: String,
    ollama_client: Arc<Ollama>,
    discord_http: Arc<HttpClient>,
    discord_cache: Arc<DefaultInMemoryCache>,
    interaction_handlers: Arc<InteractionHandlers>,
    reminder_manager: Arc<ReminderManager>,
}

const MIGRATIONS: &[Migration] = &[include_str!(
    "../migrations/0001_create_reminders_table.sql"
)];

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
    tracing_subscriber::fmt::init();
    dotenvy::dotenv().ok();

    let database = Connection::open("cuby.db")?;
    crate::database::execute_migrations(&database, MIGRATIONS);
    let database = Arc::new(Mutex::new(database));

    let ollama_model = std::env::var("OLLAMA_MODEL").expect("OLLAMA_MODEL env var is missing.");
    let ollama_url = std::env::var("OLLAMA_URL").expect("OLLAMA_URL env var is missing.");
    let ollama_token = std::env::var("OLLAMA_TOKEN").expect("OLLAMA_TOKEN env var is missing.");
    let mut ollama_headers = HeaderMap::new();
    ollama_headers.append("Authorization", format!("Bearer {}", ollama_token).parse()?);
    let ollama = Ollama::builder()
        .url(ollama_url)
        .request_headers(ollama_headers)
        .build();

    let discord_token = std::env::var("DISCORD_TOKEN").expect("DISCORD_TOKEN env var is missing.");
    let discord_intents =
        Intents::GUILD_MESSAGES | Intents::DIRECT_MESSAGES | Intents::MESSAGE_CONTENT;

    let mut shard = Shard::new(ShardId::ONE, discord_token.clone(), discord_intents);
    let http = HttpClient::new(discord_token);
    let cache = DefaultInMemoryCache::builder()
        .resource_types(ResourceType::USER_CURRENT | ResourceType::MESSAGE)
        .build();

    let interaction_client =
        http.interaction(http.current_user_application().await?.model().await?.id);
    let interaction_handlers = interactions::get_interaction_handlers();
    interactions::register_commands(interaction_client, &interaction_handlers).await?;

    let mut reminder_manager = ReminderManager::new(database);
    let mut reminder_rx = reminder_manager.take_event_receiver();
    let reminder_manager = Arc::new(reminder_manager);

    // Start watching the next pending reminder
    reminder_manager.schedule_next().await;

    let state = State {
        ollama_model: ollama_model,
        ollama_client: Arc::new(ollama),
        discord_http: Arc::new(http),
        discord_cache: Arc::new(cache),
        interaction_handlers: Arc::new(interaction_handlers),
        reminder_manager: reminder_manager.clone(),
    };

    loop {
        tokio::select! {
            item = shard.next_event(EventTypeFlags::all()) => {
                let Some(item) = item else {
                    continue;
                };
                let Ok(event) = item else {
                    tracing::warn!(source = ?item.unwrap_err(), "error receiving event");
                    continue;
                };

                state.discord_cache.update(&event);
                tokio::spawn(handle_gateway_event(event, state.clone()));
            }
            Some(reminder) = reminder_rx.recv() => {
                tracing::info!("Processing reminder {}: {:?}", reminder.id, reminder.remind_message);

                if let Err(e) = state.reminder_manager.delete(reminder.id).await {
                    tracing::error!("Failed to delete reminder {}: {}", reminder.id, e);
                }

                tokio::spawn(handle_reminder_event(reminder, state.clone()));
            }
        }
    }
}

async fn handle_gateway_event(
    event: Event,
    state: State,
) -> Result<(), Box<dyn Error + Send + Sync>> {
    match event {
        Event::InteractionCreate(event) => {
            let interaction = event.0;
            interactions::handle_interaction(interaction, state).await?;
        }
        Event::MessageCreate(message) => {
            ai::handle_incoming_message(state, &message).await;
        }
        Event::Ready(event) => {
            let user = event.user;
            tracing::info!("Logged in as {}#{}", user.name, user.discriminator);
        }
        _ => {}
    }

    Ok(())
}

async fn handle_reminder_event(reminder: reminder::Reminder, state: State) {
    let now = chrono::Utc::now();
    let relative = {
        let diff = now - reminder.created_at;
        let secs = diff.num_seconds();
        if secs < 60 {
            format!("{} second{}", secs, if secs == 1 { "" } else { "s" })
        } else if secs < 3600 {
            let mins = secs / 60;
            format!("{} minute{}", mins, if mins == 1 { "" } else { "s" })
        } else if secs < 86400 {
            let hours = secs / 3600;
            format!("{} hour{}", hours, if hours == 1 { "" } else { "s" })
        } else {
            let days = secs / 86400;
            format!("{} day{}", days, if days == 1 { "" } else { "s" })
        }
    };

    let message_part = match &reminder.remind_message {
        Some(msg) if !msg.is_empty() => format!("`{}`", msg),
        _ => "something".into(),
    };

    let content = if reminder.created_for_id == reminder.created_by_id {
        format!(
            "<@{}>, you wanted to be reminded about {} {} ago",
            reminder.created_for_id, message_part, relative
        )
    } else {
        format!(
            "<@{}>, <@{}> wanted to remind you about {} {} ago",
            reminder.created_for_id, reminder.created_by_id, message_part, relative
        )
    };

    let result = match reminder.remind_location {
        RemindLocation::Channel => {
            let channel_id = twilight_model::id::Id::new(reminder.source_channel_id as u64);
            let message_id = twilight_model::id::Id::new(reminder.source_message_id as u64);
            state
                .discord_http
                .create_message(channel_id)
                .content(&content)
                .reply(message_id)
                .await
        }
        RemindLocation::Dm => {
            let user_id = twilight_model::id::Id::new(reminder.created_for_id as u64);
            match state.discord_http.create_private_channel(user_id).await {
                Ok(resp) => {
                    let dm = resp.model().await;
                    match dm {
                        Ok(dm_channel) => {
                            state
                                .discord_http
                                .create_message(dm_channel.id)
                                .content(&content)
                                .await
                        }
                        Err(e) => {
                            tracing::error!("Failed to get DM channel: {}", e);
                            return;
                        }
                    }
                }
                Err(e) => {
                    tracing::error!("Failed to create DM channel: {}", e);
                    return;
                }
            }
        }
    };

    if let Err(e) = result {
        tracing::error!("Failed to send reminder {}: {}", reminder.id, e);
    }
}
