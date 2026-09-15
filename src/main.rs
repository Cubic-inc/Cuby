use std::{error::Error, sync::Arc};

use ollama_rs::Ollama;
use reqwest::header::HeaderMap;
use twilight_cache_inmemory::{DefaultInMemoryCache, ResourceType};
use twilight_gateway::{Event, EventTypeFlags, Intents, Shard, ShardId, StreamExt as _};
use twilight_http::Client as HttpClient;

use crate::interactions::InteractionHandlers;

mod ai;
pub mod extensions;
mod interactions;
pub mod utility;

#[derive(Clone)]
struct State {
    ollama_model: String,
    ollama_client: Arc<Ollama>,
    discord_http: Arc<HttpClient>,
    discord_cache: Arc<DefaultInMemoryCache>,
    interaction_handlers: Arc<InteractionHandlers>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
    tracing_subscriber::fmt::init();
    dotenvy::dotenv().ok();

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

    let state = State {
        ollama_model: ollama_model,
        ollama_client: Arc::new(ollama),
        discord_http: Arc::new(http),
        discord_cache: Arc::new(cache),
        interaction_handlers: Arc::new(interaction_handlers),
    };

    while let Some(item) = shard.next_event(EventTypeFlags::all()).await {
        let Ok(event) = item else {
            tracing::warn!(source = ?item.unwrap_err(), "error receiving event");
            continue;
        };

        state.discord_cache.update(&event);
        tokio::spawn(handle_event(event, state.clone()));
    }

    Ok(())
}

async fn handle_event(event: Event, state: State) -> Result<(), Box<dyn Error + Send + Sync>> {
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
