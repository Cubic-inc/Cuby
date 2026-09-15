use twilight_model::application::command::CommandType;
use twilight_util::builder::command::CommandBuilder;

use crate::{State, interactions::InteractionHandler};

pub struct PrimaryEntryPointInteractionHandler;

#[async_trait::async_trait]
impl InteractionHandler for PrimaryEntryPointInteractionHandler {
    fn name(&self) -> &str {
        "launch"
    }

    fn builder(&self) -> CommandBuilder {
        CommandBuilder::new("launch", "Launches the activity", CommandType::Unknown(4))
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        use twilight_model::http::interaction::{InteractionResponse, InteractionResponseType};

        let response = InteractionResponse {
            kind: InteractionResponseType::DeferredChannelMessageWithSource,
            data: None,
        };
        state
            .discord_http
            .interaction(interaction.application_id)
            .create_response(interaction.id, &interaction.token, &response)
            .await?;
        Ok(())
    }
}
