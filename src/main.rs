use std::{error::Error, sync::Arc};

use twilight_cache_inmemory::{DefaultInMemoryCache, ResourceType};
use twilight_gateway::{Event, EventTypeFlags, Intents, Shard, ShardId, StreamExt};
use twilight_http::Client as HttpClient;

use crate::interactions::InteractionHandlers;

pub mod extensions;
mod interactions;
pub mod utility;

#[derive(Clone)]
struct State {
    http: Arc<HttpClient>,
    interaction_handlers: Arc<InteractionHandlers>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error + Send + Sync>> {
    tracing_subscriber::fmt::init();
    dotenvy::dotenv().ok();

    let token = std::env::var("DISCORD_TOKEN")?;
    let intents = Intents::GUILD_MESSAGES | Intents::DIRECT_MESSAGES | Intents::MESSAGE_CONTENT;

    let mut shard = Shard::new(ShardId::ONE, token.clone(), intents);
    let http = HttpClient::new(token);
    let cache = DefaultInMemoryCache::builder()
        .resource_types(ResourceType::MESSAGE)
        .build();

    let interaction_client =
        http.interaction(http.current_user_application().await?.model().await?.id);
    let interaction_handlers = interactions::get_interaction_handlers();
    interactions::register_commands(interaction_client, &interaction_handlers).await?;

    let state = State {
        http: Arc::new(http),
        interaction_handlers: Arc::new(interaction_handlers),
    };

    while let Some(item) = shard.next_event(EventTypeFlags::all()).await {
        let Ok(event) = item else {
            tracing::warn!(source = ?item.unwrap_err(), "error receiving event");
            continue;
        };

        cache.update(&event);
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
        Event::MessageCreate(message) => {}
        Event::Ready(event) => {
            let user = event.user;
            tracing::info!("Logged in as {}#{}", user.name, user.discriminator);
        }
        _ => {}
    }

    Ok(())
}
