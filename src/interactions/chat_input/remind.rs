use twilight_mention::Mention;
use twilight_model::{
    application::command::CommandType,
    application::interaction::InteractionContextType,
    channel::message::MessageFlags,
};
use twilight_util::builder::{
    InteractionResponseDataBuilder,
    command::{CommandBuilder, IntegerBuilder, SubCommandBuilder, UserBuilder},
};

use crate::{
    State,
    extensions::{
        interaction::InteractionExt, interaction_response_data::InteractionResponseDataExt,
    },
    interactions::InteractionHandler,
    reminder::{compute_remind_at, format_duration, RemindLocation},
};

pub struct RemindChatInputCommandHandler;

#[async_trait::async_trait]
impl InteractionHandler for RemindChatInputCommandHandler {
    fn name(&self) -> &str {
        "remind"
    }

    fn builder(&self) -> CommandBuilder {
        let me_sub = SubCommandBuilder::new("me", "Set a reminder for yourself")
            .option(IntegerBuilder::new("seconds", "Number of seconds").min_value(0))
            .option(IntegerBuilder::new("minutes", "Number of minutes").min_value(0))
            .option(IntegerBuilder::new("hours", "Number of hours").min_value(0))
            .option(IntegerBuilder::new("days", "Number of days").min_value(0))
            .option(IntegerBuilder::new("weeks", "Number of weeks").min_value(0))
            .option(IntegerBuilder::new("months", "Number of months").min_value(0))
            .option(IntegerBuilder::new("years", "Number of years").min_value(0))
            .option(twilight_util::builder::command::StringBuilder::new(
                "reason",
                "What to remind you about",
            ));

        let them_sub = SubCommandBuilder::new("them", "Set a reminder for someone else")
            .option(UserBuilder::new("user", "The user to remind").required(true))
            .option(IntegerBuilder::new("seconds", "Number of seconds").min_value(0))
            .option(IntegerBuilder::new("minutes", "Number of minutes").min_value(0))
            .option(IntegerBuilder::new("hours", "Number of hours").min_value(0))
            .option(IntegerBuilder::new("days", "Number of days").min_value(0))
            .option(IntegerBuilder::new("weeks", "Number of weeks").min_value(0))
            .option(IntegerBuilder::new("months", "Number of months").min_value(0))
            .option(IntegerBuilder::new("years", "Number of years").min_value(0))
            .option(twilight_util::builder::command::StringBuilder::new(
                "reason",
                "What to remind them about",
            ));

        CommandBuilder::new("remind", "Set a reminder", CommandType::ChatInput)
            .contexts(vec![InteractionContextType::Guild])
            .option(me_sub)
            .option(them_sub)
    }

    async fn handler(
        &self,
        interaction: twilight_model::application::interaction::Interaction,
        state: State,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let interaction_client = state.discord_http.interaction(interaction.application_id);

        let Some(author) = &interaction.author() else {
            tracing::warn!("Received interaction with no author");
            return Ok(());
        };

        let Some(cmd) = interaction.command_data() else {
            tracing::warn!("Received interaction with no data");
            return Ok(());
        };

        let sub_name = cmd.options.iter().find_map(|o| {
            if let twilight_model::application::interaction::application_command::CommandOptionValue::SubCommand(_) = &o.value {
                Some(o.name.as_str())
            } else {
                None
            }
        });

        let sub_options = cmd.options.iter().find_map(|o| {
            if let twilight_model::application::interaction::application_command::CommandOptionValue::SubCommand(opts) = &o.value {
                Some(opts.as_slice())
            } else {
                None
            }
        });

        let Some(sub_name) = sub_name else {
            let response = InteractionResponseDataBuilder::new()
                .content("Please use `/remind me` or `/remind them`.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;
            return Ok(());
        };

        let Some(sub_options) = sub_options else {
            return Ok(());
        };

        let get_int = |name: &str| -> Option<i64> {
            sub_options.iter().find_map(|o| {
                if o.name == name {
                    if let twilight_model::application::interaction::application_command::CommandOptionValue::Integer(i) = &o.value {
                        return Some(*i);
                    }
                }
                None
            })
        };

        let get_str = |name: &str| -> Option<&str> {
            sub_options.iter().find_map(|o| {
                if o.name == name {
                    if let twilight_model::application::interaction::application_command::CommandOptionValue::String(s) = &o.value {
                        return Some(s.as_str());
                    }
                }
                None
            })
        };

        let seconds = get_int("seconds");
        let minutes = get_int("minutes");
        let hours = get_int("hours");
        let days = get_int("days");
        let weeks = get_int("weeks");
        let months = get_int("months");
        let years = get_int("years");
        let reason = get_str("reason");

        let Some(remind_at) =
            compute_remind_at(seconds, minutes, hours, days, weeks, months, years)
        else {
            let response = InteractionResponseDataBuilder::new()
                .content("Please provide at least one time unit greater than zero.")
                .flags(MessageFlags::EPHEMERAL)
                .build()
                .into_channel_message_with_source();

            interaction_client
                .create_response(interaction.id, &interaction.token, &response)
                .await?;
            return Ok(());
        };

        let author_id: i64 = author.id.get() as i64;

        let Some(guild_id) = interaction.guild_id else {
            tracing::warn!("remind invoked without a guild_id");
            return Ok(());
        };

        let Some(channel) = &interaction.channel else {
            tracing::warn!("remind invoked without a channel");
            return Ok(());
        };

        let guild_id: i64 = guild_id.get() as i64;
        let channel_id: i64 = channel.id.get() as i64;

        let (target_id, target_mention) = match sub_name {
            "me" => (author_id, author.mention().to_string()),
            "them" => {
                let get_user = |name: &str| -> Option<
                    twilight_model::id::Id<twilight_model::id::marker::UserMarker>,
                > {
                    sub_options.iter().find_map(|o| {
                        if o.name == name {
                            if let twilight_model::application::interaction::application_command::CommandOptionValue::User(id) = &o.value {
                                return Some(*id);
                            }
                        }
                        None
                    })
                };

                let Some(target_user_id) = get_user("user") else {
                    tracing::warn!("remind them invoked without a user option");
                    return Ok(());
                };

                let mention = cmd
                    .resolved
                    .as_ref()
                    .and_then(|r| r.users.get(&target_user_id))
                    .map(|u| u.mention().to_string())
                    .unwrap_or_else(|| format!("<@{}>", target_user_id));

                (target_user_id.get() as i64, mention)
            }
            _ => unreachable!(),
        };

        // Respond with loading state
        let response = InteractionResponseDataBuilder::new()
            .content("Setting reminder...")
            .build()
            .into_channel_message_with_source();

        interaction_client
            .create_response(interaction.id, &interaction.token, &response)
            .await?;

        // Get the message ID from the response
        let response_msg = interaction_client
            .response(&interaction.token)
            .await?
            .model()
            .await?;

        let message_id: i64 = response_msg.id.get() as i64;

        // Create the reminder with the loading message ID
        let reminder = state
            .reminder_manager
            .create(
                target_id,
                author_id,
                reason,
                remind_at,
                RemindLocation::Channel,
                guild_id,
                channel_id,
                message_id,
            )
            .await?;

        // Build the final content
        let duration_str = format_duration(seconds, minutes, hours, days, weeks, months, years);
        let message_part = match &reminder.remind_message {
            Some(msg) if !msg.is_empty() => format!(" about {}", msg),
            _ => String::new(),
        };
        let content = match sub_name {
            "me" => format!(
                "I'll remind you{} in {} at <t:{}:f>",
                message_part,
                duration_str,
                remind_at.timestamp(),
            ),
            "them" => format!(
                "I'll remind {}{} in {} at <t:{}:f>",
                target_mention,
                message_part,
                duration_str,
                remind_at.timestamp(),
            ),
            _ => unreachable!(),
        };

        // Update the response with the actual content
        interaction_client
            .update_response(&interaction.token)
            .content(Some(&content))
            .await?;

        Ok(())
    }
}
