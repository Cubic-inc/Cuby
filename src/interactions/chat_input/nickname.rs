use twilight_http::request::AuditLogReason;
use twilight_mention::Mention;
use twilight_model::{
    application::{command::CommandType, interaction::InteractionContextType},
    channel::message::MessageFlags,
};
use twilight_util::builder::{
    InteractionResponseDataBuilder,
    command::{CommandBuilder, StringBuilder, UserBuilder},
};

use crate::{
    State,
    extensions::{
        command_data::CommandDataExt, interaction::InteractionExt,
        interaction_response_data::InteractionResponseDataExt,
    },
    interactions::InteractionHandler,
};

pub struct NicknameChatInputCommandHandler;

#[async_trait::async_trait]
impl InteractionHandler for NicknameChatInputCommandHandler {
    fn name(&self) -> &str {
        "nickname"
    }

    fn builder(&self) -> CommandBuilder {
        CommandBuilder::new(
            self.name(),
            "Change someone's nickname",
            CommandType::ChatInput,
        )
        .contexts(vec![InteractionContextType::Guild])
        .option(UserBuilder::new("user", "User to change nickname of").required(true))
        .option(StringBuilder::new("name", "New nickname"))
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let interaction_http = state.discord_http.interaction(interaction.application_id);

        let command_data = interaction.command_data().ok_or("No command data found")?;
        let user_id = command_data.get_user("user").ok_or("No user id found")?;
        let new_nickname = command_data.get_string("name");

        let user_is_bot = match state.discord_cache.user(user_id) {
            Some(user) => user.bot,
            None => {
                let resp = state.discord_http.user(user_id).await;
                match resp {
                    Ok(r) => r.model().await.map(|u| u.bot).unwrap_or(false),
                    Err(_) => false,
                }
            }
        };

        let content = if user_is_bot {
            "Cannot change nickname of a bot user".into()
        } else {
            let author = interaction.author().ok_or("Author is missing")?;
            let author_name = author.global_name.as_ref().unwrap_or(&author.name);

            match state
                .discord_http
                .update_guild_member(interaction.guild_id.ok_or("Guild id is missing")?, user_id)
                .nick(new_nickname)
                .reason(format!("Nickname changed by {}", author_name).as_str())
                .await
            {
                Ok(_) => match new_nickname {
                    Some(new_nickname) => format!(
                        "Changed nickname of {} to `{}`",
                        user_id.mention(),
                        new_nickname
                    ),
                    None => format!("Reset nickname of {}", user_id.mention()),
                },
                Err(e) => {
                    tracing::error!("Failed to change nickname: {:?}", e);
                    "Failed to change nickname".into()
                }
            }
        };

        let response = InteractionResponseDataBuilder::new()
            .content(content)
            .flags(MessageFlags::EPHEMERAL)
            .build()
            .into_channel_message_with_source();

        interaction_http
            .create_response(interaction.id, &interaction.token, &response)
            .await?;

        Ok(())
    }
}
