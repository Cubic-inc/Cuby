use std::{collections::HashMap, time::Duration};

use twilight_model::{
    application::{command::CommandType, interaction::InteractionContextType},
    channel::{ChannelType, message::MessageFlags},
    id::{Id, marker::GuildMarker},
};
use twilight_util::builder::{InteractionResponseDataBuilder, command::CommandBuilder};

use crate::{
    State, extensions::interaction_response_data::InteractionResponseDataExt,
    interactions::InteractionHandler,
};

const RATE_LIMIT: Duration = Duration::from_secs(120);

pub struct ServerShuffleChatInputCommandHandler {
    last_used: tokio::sync::Mutex<HashMap<Id<GuildMarker>, std::time::Instant>>,
}

impl ServerShuffleChatInputCommandHandler {
    pub fn new() -> Self {
        Self {
            last_used: tokio::sync::Mutex::new(HashMap::new()),
        }
    }

    /// Returns the remaining seconds of the rate limit for a guild, or `None` if no rate limit is active.
    pub async fn ratelimit_remaining(&self, guild_id: Id<GuildMarker>) -> Option<u64> {
        let last_used = self.last_used.lock().await;
        let last = last_used.get(&guild_id)?;
        let remaining = RATE_LIMIT.saturating_sub(last.elapsed());
        (remaining > Duration::ZERO).then_some(remaining.as_secs())
    }

    /// Activates a new rate limit for the given guild.
    pub async fn activate_ratelimit(&self, guild_id: Id<GuildMarker>) {
        let mut last_used = self.last_used.lock().await;
        last_used.insert(guild_id, std::time::Instant::now());
    }
}

#[async_trait::async_trait]
impl InteractionHandler for ServerShuffleChatInputCommandHandler {
    fn name(&self) -> &str {
        "servershuffle"
    }

    fn builder(&self) -> CommandBuilder {
        CommandBuilder::new(
            "servershuffle",
            "Reset voice server of the vc you are currently in",
            CommandType::ChatInput,
        )
        .contexts(vec![InteractionContextType::Guild])
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let Some(guild_id) = interaction.guild_id else {
            tracing::warn!("servershuffle invoked without a guild_id");
            return Ok(());
        };

        let Some(author_id) = interaction.author_id() else {
            tracing::warn!("servershuffle invoked without an author");
            return Ok(());
        };

        let interaction_client = state.http.interaction(interaction.application_id);

        // Rate limit check: only allow one shuffle per guild every 2 minutes.
        if let Some(secs) = self.ratelimit_remaining(guild_id).await {
            let response = InteractionResponseDataBuilder::new()
                .content(format!(
                    "This command is on cooldown for this server. Try again in {secs} seconds."
                ))
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        } else {
            self.activate_ratelimit(guild_id).await;
        }

        // Check if the user is in a voice channel by fetching their voice state.
        // The Discord API returns an error if the user is not in a voice channel.
        let voice_state = state.http.user_voice_state(guild_id, author_id).await;

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

        // Fetch the channel to get the current RTC region.
        let channel = state.http.channel(channel_id).await?.model().await?;

        if channel.kind != ChannelType::GuildVoice {
            let response = InteractionResponseDataBuilder::new()
                .content("This command can only be used in a voice channel.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        }

        let Some(original_region) = channel
            .rtc_region
            .as_deref()
            .filter(|r| *r != "automatic")
            .map(str::to_owned)
        else {
            let response =
                    InteractionResponseDataBuilder::new()
                        .content("I'm unable to shuffle the voice region at this time because it is set to automatic.")
                        .flags(MessageFlags::EPHEMERAL)
                        .build().into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        };

        // Fetch available voice regions and pick one that differs from the current.
        let regions = state
            .http
            .guild_voice_regions(guild_id)
            .await?
            .models()
            .await?;

        let alternative = regions
            .iter()
            .find(|r| !r.deprecated && original_region != r.id)
            .map(|r| r.id.clone());

        let Some(new_region) = alternative else {
            tracing::warn!("No alternative voice region found for guild {guild_id}");
            let response = InteractionResponseDataBuilder::new()
                .content("Could not find an alternative voice region to shuffle to.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;

            return Ok(());
        };

        // Respond to the user that the shuffle is happening.
        let response = InteractionResponseDataBuilder::new()
            .content("Shuffling voice region, please wait a moment...")
            .flags(MessageFlags::EPHEMERAL)
            .build()
            .into_channel_message_with_source();

        interaction_client
            .create_response(interaction.id, &interaction.token, &response)
            .await?;

        // Set the channel to the alternative region.
        state
            .http
            .update_channel(channel_id)
            .rtc_region(Some(&new_region))
            .await?;

        // Wait a few seconds, then restore the original region.
        tokio::time::sleep(std::time::Duration::from_secs(3)).await;

        state
            .http
            .update_channel(channel_id)
            .rtc_region(Some(&original_region))
            .await?;

        // Update the original response to indicate completion.
        interaction_client
            .update_response(&interaction.token)
            .content(Some("Voice region shuffle complete!"))
            .await?;

        Ok(())
    }
}
