use std::sync::Arc;

use twilight_http::client::InteractionClient;
use twilight_model::application::interaction::{Interaction, InteractionData::ApplicationCommand};
use twilight_util::builder::command::CommandBuilder;

use crate::State;

mod chat_input;
mod entry_point;

#[async_trait::async_trait]
pub trait InteractionHandler {
    fn name(&self) -> &str;
    fn builder(&self) -> CommandBuilder;
    async fn handler(
        &self,
        interaction: Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>>;
}

pub type InteractionHandlers = Vec<Box<dyn InteractionHandler + Send + Sync>>;

pub fn get_interaction_handlers() -> InteractionHandlers {
    let mut handlers: Vec<Box<dyn InteractionHandler + Send + Sync>> = Vec::new();
    handlers.extend(chat_input::get_chat_input_interaction_handlers());
    handlers.extend(entry_point::get_entry_point_interaction_handlers());
    return handlers;
}

pub async fn register_commands(
    interaction_client: InteractionClient<'_>,
    interaction_handlers: &InteractionHandlers,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let commands: Vec<_> = interaction_handlers
        .iter()
        .map(|handler| handler.builder().build())
        .collect();
    interaction_client.set_global_commands(&commands).await?;

    Ok(())
}

pub async fn handle_interaction(
    interaction: Interaction,
    state: State,
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let Some(data) = &interaction.data else {
        tracing::warn!("Received interaction with no data");
        return Ok(());
    };

    match data {
        ApplicationCommand(data) => {
            let handler = state
                .interaction_handlers
                .iter()
                .find(|h| h.name() == data.name.as_str())
                .ok_or_else(|| {
                    tracing::warn!(
                        command_name = data.name.as_str(),
                        "No handler found for command"
                    );
                    "No handler found for command"
                })?;

            handler.handler(interaction, state.clone()).await?;
            Ok(())
        }
        _ => {
            tracing::warn!(
                interaction_type = ?interaction.kind,
                "Received interaction of unsupported type"
            );
            Ok(())
        }
    }
}
