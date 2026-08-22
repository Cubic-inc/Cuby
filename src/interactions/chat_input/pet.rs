use petpet_rs::PetpetOptions;
use twilight_mention::Mention;
use twilight_model::{
    application::{
        command::CommandType,
        interaction::{InteractionContextType, InteractionData},
    },
    channel::message::MessageFlags,
    http::{
        attachment::Attachment,
        interaction::{InteractionResponse, InteractionResponseType},
    },
};
use twilight_util::builder::{
    InteractionResponseDataBuilder,
    command::{CommandBuilder, UserBuilder},
};

use crate::{interactions::InteractionHandler, utility::cdn::format_avatar_url};

pub struct PetChatInputCommandHandler;

#[async_trait::async_trait]
impl InteractionHandler for PetChatInputCommandHandler {
    fn name(&self) -> &str {
        "pet"
    }

    fn builder(&self) -> CommandBuilder {
        CommandBuilder::new("pet", "Pet someone", CommandType::ChatInput)
            .contexts(vec![InteractionContextType::Guild])
            .option(UserBuilder::new("target", "The user to pet").required(true))
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        http: std::sync::Arc<twilight_http::Client>,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let Some(author) = &interaction.author() else {
            tracing::warn!("Received interaction with no author");
            return Ok(());
        };

        let Some(InteractionData::ApplicationCommand(data)) = &interaction.data else {
            tracing::warn!("Received interaction with no data");
            return Ok(());
        };

        let Some(resolved_options) = &data.resolved else {
            tracing::warn!("Received interaction with no resolved data");
            return Ok(());
        };

        let Some(target_user) = resolved_options.users.iter().next() else {
            tracing::warn!("Received interaction with no target member");
            return Ok(());
        };

        let Some(avatar_url) = format_avatar_url(&target_user.1, "png", 512) else {
            tracing::warn!("Received interaction with no avatar");
            return Ok(());
        };

        let Ok(response) = reqwest::get(avatar_url).await else {
            tracing::warn!("Failed to fetch avatar image");
            return Ok(());
        };

        let Ok(image_bytes) = response.bytes().await else {
            tracing::warn!("Failed to read avatar image bytes");
            return Ok(());
        };

        let image = image::load_from_memory(&image_bytes).map_err(|e| {
            tracing::warn!(error = ?e, "Failed to load avatar image");
            e
        })?;

        let pet_image = petpet_rs::petpet(
            &image,
            PetpetOptions {
                resolution: 256,
                rounded: true,
                quality: 30,
            },
        );

        let content = format!(
            "{} is petting {}",
            author.mention(),
            target_user.1.mention()
        );

        let response_data = InteractionResponseDataBuilder::new()
            .content(content)
            .attachments(vec![Attachment::from_bytes(
                "petpet.gif".to_string(),
                pet_image,
                1,
            )])
            .flags(MessageFlags::SUPPRESS_NOTIFICATIONS)
            .build();

        let response = InteractionResponse {
            kind: InteractionResponseType::ChannelMessageWithSource,
            data: Some(response_data),
        };

        http.interaction(interaction.application_id)
            .create_response(interaction.id, &interaction.token, &response)
            .await?;

        Ok(())
    }
}
