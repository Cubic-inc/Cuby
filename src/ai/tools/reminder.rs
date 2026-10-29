use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use twilight_model::{
    channel::Message,
    id::{Id, marker::UserMarker},
};

use crate::{
    State,
    extensions::tool_function_info::ToolFunctionInfoExt,
    reminder::{RemindLocation, compute_remind_at, format_duration},
};

use super::{MessageDraft, Tool};

pub struct ReminderTool;

#[async_trait::async_trait]
impl Tool for ReminderTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "set_reminder".to_string(),
            description: "Sets a reminder. By default it reminds the person who asked; pass user_id \
                 to remind someone else."
                .to_string(),
            parameters: json_schema!({
                "type":"object",
                "properties": {
                    "seconds": {
                        "type": "integer",
                        "description": "Number of seconds from now."
                    },
                    "minutes": {
                        "type": "integer",
                        "description": "Number of minutes from now."
                    },
                    "hours": {
                        "type": "integer",
                        "description": "Number of hours from now."
                    },
                    "days": {
                        "type": "integer",
                        "description": "Number of days from now."
                    },
                    "weeks": {
                        "type": "integer",
                        "description": "Number of weeks from now."
                    },
                    "user_id": {
                        "type": "string",
                        "description": "The Discord user id of the person to remind, as a plain number like 123456789012345678. Omit to remind the person who asked."
                    },
                    "reason": {
                        "type": "string",
                        "description": "The message to be reminded of. Optional."
                    }
                },
                "required": []
            }),
        }
        .into_tool_info()
    }

    async fn execute(
        &self,
        state: State,
        _message: &Message,
        _draft: &mut MessageDraft,
        arguments: serde_json::Value,
    ) -> String {
        let get_int = |name: &str| -> Option<i64> { arguments.get(name).and_then(|v| v.as_i64()) };

        let seconds = get_int("seconds");
        let minutes = get_int("minutes");
        let hours = get_int("hours");
        let days = get_int("days");
        let weeks = get_int("weeks");
        let months = get_int("months");
        let years = get_int("years");
        let reason = arguments.get("reason").and_then(|v| v.as_str());

        let target = target_user_id(&arguments);

        if let Some(id) = target {
            if user_is_bot(&state, id).await {
                return "Cannot set a reminder for a bot.".to_string();
            }
        }

        let Some(_remind_at) =
            compute_remind_at(seconds, minutes, hours, days, weeks, months, years)
        else {
            return "Please provide at least one time unit greater than zero.".to_string();
        };

        let duration_str = format_duration(seconds, minutes, hours, days, weeks, months, years);
        let reason_part = match reason {
            Some(r) if !r.is_empty() => format!(": {}", r),
            _ => String::new(),
        };

        match target {
            Some(id) => format!(
                "Reminder set to remind <@{}> in {}{}.",
                id, duration_str, reason_part
            ),
            None => format!("Reminder set for {} from now{}.", duration_str, reason_part),
        }
    }

    async fn post_execute(&self, state: State, message: &Message, arguments: serde_json::Value) {
        let get_int = |name: &str| -> Option<i64> { arguments.get(name).and_then(|v| v.as_i64()) };

        let seconds = get_int("seconds");
        let minutes = get_int("minutes");
        let hours = get_int("hours");
        let days = get_int("days");
        let weeks = get_int("weeks");
        let months = get_int("months");
        let years = get_int("years");
        let reason = arguments.get("reason").and_then(|v| v.as_str());

        let Some(remind_at) =
            compute_remind_at(seconds, minutes, hours, days, weeks, months, years)
        else {
            return;
        };

        let author_id: i64 = message.author.id.get() as i64;
        let created_for_id = match target_user_id(&arguments) {
            Some(id) => {
                if user_is_bot(&state, id).await {
                    return;
                }
                id
            }
            None => author_id,
        };
        let channel_id: i64 = message.channel_id.get() as i64;
        let guild_id: i64 = message.guild_id.map(|id| id.get() as i64).unwrap_or(0);
        let message_id: i64 = message.id.get() as i64;

        if let Err(e) = state
            .reminder_manager
            .create(
                created_for_id,
                author_id,
                reason,
                remind_at,
                RemindLocation::Channel,
                guild_id,
                channel_id,
                message_id,
            )
            .await
        {
            tracing::error!("Failed to create reminder from AI tool: {}", e);
        }
    }
}

/// Reads the optional `user_id` argument as a plain numeric Discord user id.
/// Returns `None` when it is absent or not a valid id, in which case the
/// reminder is set for the person who asked.
fn target_user_id(arguments: &serde_json::Value) -> Option<i64> {
    arguments
        .get("user_id")
        .and_then(|value| value.as_str())
        .and_then(|raw| raw.trim().parse::<i64>().ok())
        .filter(|id| *id != 0)
}

/// Checks whether the given user id belongs to a bot, preferring the cache and
/// falling back to a REST lookup. Unknown users are treated as non-bots.
async fn user_is_bot(state: &State, user_id: i64) -> bool {
    let user_id = Id::<UserMarker>::new(user_id as u64);

    match state.discord_cache.user(user_id) {
        Some(user) => user.bot,
        None => match state.discord_http.user(user_id).await {
            Ok(resp) => resp.model().await.map(|user| user.bot).unwrap_or(false),
            Err(_) => false,
        },
    }
}
