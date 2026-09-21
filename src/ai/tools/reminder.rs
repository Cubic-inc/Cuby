use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use twilight_model::channel::Message;

use crate::{
    State,
    extensions::tool_function_info::ToolFunctionInfoExt,
    reminder::{compute_remind_at, format_duration, RemindLocation},
};

use super::Tool;

pub struct ReminderTool;

#[async_trait::async_trait]
impl Tool for ReminderTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "set_reminder".to_string(),
            description: "Sets a reminder for the user.".to_string(),
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

    async fn execute(&self, _state: State, arguments: serde_json::Value) -> String {
        let get_int = |name: &str| -> Option<i64> {
            arguments.get(name).and_then(|v| v.as_i64())
        };

        let seconds = get_int("seconds");
        let minutes = get_int("minutes");
        let hours = get_int("hours");
        let days = get_int("days");
        let weeks = get_int("weeks");
        let months = get_int("months");
        let years = get_int("years");
        let reason = arguments.get("reason").and_then(|v| v.as_str());

        let Some(_remind_at) = compute_remind_at(seconds, minutes, hours, days, weeks, months, years)
        else {
            return "Please provide at least one time unit greater than zero.".to_string();
        };

        let duration_str = format_duration(seconds, minutes, hours, days, weeks, months, years);

        // Store the computed values so post_execute can use them
        // For now, we return the confirmation string
        format!(
            "Reminder set for {} from now{}.",
            duration_str,
            match reason {
                Some(r) if !r.is_empty() => format!(": {}", r),
                _ => String::new(),
            }
        )
    }

    async fn post_execute(&self, state: State, message: &Message, arguments: serde_json::Value) {
        let get_int = |name: &str| -> Option<i64> {
            arguments.get(name).and_then(|v| v.as_i64())
        };

        let seconds = get_int("seconds");
        let minutes = get_int("minutes");
        let hours = get_int("hours");
        let days = get_int("days");
        let weeks = get_int("weeks");
        let months = get_int("months");
        let years = get_int("years");
        let reason = arguments.get("reason").and_then(|v| v.as_str());

        let Some(remind_at) = compute_remind_at(seconds, minutes, hours, days, weeks, months, years)
        else {
            return;
        };

        let author_id: i64 = message.author.id.get() as i64;
        let channel_id: i64 = message.channel_id.get() as i64;
        let guild_id: i64 = message.guild_id.map(|id| id.get() as i64).unwrap_or(0);
        let message_id: i64 = message.id.get() as i64;

        if let Err(e) = state
            .reminder_manager
            .create(
                author_id,
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
