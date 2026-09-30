use twilight_http::request::AuditLogReason;
use twilight_model::{
    application::{command::CommandType, interaction::InteractionContextType},
    channel::message::MessageFlags,
};
use twilight_util::builder::{
    InteractionResponseDataBuilder,
    command::{CommandBuilder, StringBuilder},
};

use crate::{
    State,
    extensions::{
        command_data::CommandDataExt, interaction::InteractionExt,
        interaction_response_data::InteractionResponseDataExt,
    },
    interactions::InteractionHandler,
};

pub struct RenameChannelChatInputCommandHandler;

#[async_trait::async_trait]
impl InteractionHandler for RenameChannelChatInputCommandHandler {
    fn name(&self) -> &str {
        "renamechannel"
    }

    fn builder(&self) -> CommandBuilder {
        CommandBuilder::new(
            self.name(),
            "Rename the voice channel you are currently in",
            CommandType::ChatInput,
        )
        .contexts(vec![InteractionContextType::Guild])
        .option(StringBuilder::new("name", "New channel name").required(true))
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let Some(guild_id) = interaction.guild_id else {
            tracing::warn!("renamechannel invoked without a guild_id");
            return Ok(());
        };

        let Some(author_id) = interaction.author_id() else {
            tracing::warn!("renamechannel invoked without an author");
            return Ok(());
        };

        let interaction_client = state.discord_http.interaction(interaction.application_id);

        let command_data = interaction.command_data().ok_or("No command data found")?;
        let new_name = command_data
            .get_string("name")
            .ok_or("No name option found")?;

        // Check if the user is in a voice channel by fetching their voice state.
        // The Discord API returns an error if the user is not in a voice channel.
        let voice_state = state
            .discord_http
            .user_voice_state(guild_id, author_id)
            .await;

        let channel_id = match voice_state.ok() {
            Some(r) => r.model().await.ok().and_then(|v| v.channel_id),
            None => None,
        };

        let Some(channel_id) = channel_id else {
            let response = InteractionResponseDataBuilder::new()
                .content("You must be in a voice channel to use this command.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        };

        // Check that the channel ID is included in the RENAMABLE_CHANNEL_IDS
        // environment variable (comma-separated list of channel IDs).
        let channel_id_str = channel_id.get().to_string();
        let renamable = std::env::var("RENAMABLE_CHANNEL_IDS")
            .unwrap_or_default()
            .split(',')
            .map(str::trim)
            .filter(|s| !s.is_empty())
            .any(|id| id == channel_id_str);

        if !renamable {
            let response = InteractionResponseDataBuilder::new()
                .content("This voice channel cannot be renamed.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        }

        // Rename the channel.
        let author = interaction.author().ok_or("Author is missing")?;
        let author_name = author.global_name.as_ref().unwrap_or(&author.name);

        state
            .discord_http
            .update_channel(channel_id)
            .name(new_name)
            .reason(format!("Channel renamed by {}", author_name).as_str())
            .await?;

        let response = InteractionResponseDataBuilder::new()
            .content(format!("Renamed voice channel to `{}`", new_name))
            .flags(MessageFlags::EPHEMERAL)
            .build()
            .into_channel_message_with_source();

        interaction_client
            .create_response(interaction.id, &interaction.token, &response)
            .await?;

        Ok(())
    }
}
