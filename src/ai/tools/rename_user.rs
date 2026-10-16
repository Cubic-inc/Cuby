use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use serde_json::Value;
use twilight_model::{
    channel::Message,
    id::{Id, marker::UserMarker},
};

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::{MessageDraft, Tool};

/// Discord caps nicknames at 32 characters.
const MAX_NICKNAME_LENGTH: usize = 32;

pub struct RenameUserTool;

#[async_trait::async_trait]
impl Tool for RenameUserTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "rename_user".to_string(),
            description: "Changes or removes the nickname of a member of the server this message \
                 was sent in. Use this whenever someone asks you to rename a user or change \
                 someone's nickname. The server owner and bots cannot be renamed. You may also use this to mock someone if they are being mean."
                .to_string(),
            parameters: json_schema!({
                "type": "object",
                "properties": {
                    "user_id": {
                        "type": "string",
                        "description": "The numeric Discord user id of the member whose nickname to change. Use the user_id from the message that asked for this, not a username."
                    },
                    "nickname": {
                        "type": "string",
                        "description": "The new nickname, at most 32 characters. Omit or pass an empty string to remove the nickname."
                    }
                },
                "required": ["user_id"]
            }),
        }
        .into_tool_info()
    }

    async fn execute(
        &self,
        state: State,
        message: &Message,
        _draft: &mut MessageDraft,
        arguments: Value,
    ) -> String {
        let Some(user_id) = parse_user_id(&arguments) else {
            return "Error: user_id must be a Discord user id.".to_string();
        };

        let nickname = arguments
            .get("nickname")
            .and_then(|value| value.as_str())
            .filter(|nickname| !nickname.is_empty());

        if let Some(nickname) = nickname
            && !is_valid_nickname(nickname)
        {
            return format!(
                "Error: a nickname can be at most {} characters.",
                MAX_NICKNAME_LENGTH
            );
        }

        let Some(guild_id) = message.guild_id else {
            return "Error: nicknames can only be changed in a server.".to_string();
        };

        // Extract the owner id in its own statement so the cache reference is
        // dropped before any await point.
        let cached_owner_id = state
            .discord_cache
            .guild(guild_id)
            .map(|guild| guild.owner_id());

        let owner_id = match cached_owner_id {
            Some(owner_id) => Some(owner_id),
            None => match state.discord_http.guild(guild_id).await {
                Ok(resp) => resp.model().await.ok().map(|guild| guild.owner_id),
                Err(e) => {
                    tracing::warn!("Failed to fetch guild for owner check: {:?}", e);
                    None
                }
            },
        };

        let user_is_bot = match state.discord_cache.user(user_id) {
            Some(user) => user.bot,
            None => match state.discord_http.user(user_id).await {
                Ok(resp) => resp.model().await.map(|user| user.bot).unwrap_or(false),
                Err(_) => false,
            },
        };

        if owner_id == Some(user_id) {
            return "Discord does not allow bots to change the nickname of the server owner."
                .to_string();
        }
        if user_is_bot {
            return "Cannot change the nickname of a bot user.".to_string();
        }

        match state
            .discord_http
            .update_guild_member(guild_id, user_id)
            .nick(nickname)
            .await
        {
            Ok(_) => match nickname {
                Some(nickname) => {
                    format!(
                        "Changed the nickname of <@{}> to \"{}\".",
                        user_id, nickname
                    )
                }
                None => format!("Removed the nickname of <@{}>.", user_id),
            },
            Err(e) => {
                tracing::error!("Failed to change nickname via AI tool: {:?}", e);
                format!("Failed to change the nickname: {}", e)
            }
        }
    }
}

/// Reads the `user_id` argument, accepting a raw numeric id or a `<@id>` /
/// `<@!id>` mention.
fn parse_user_id(arguments: &Value) -> Option<Id<UserMarker>> {
    let raw = match arguments.get("user_id")? {
        Value::String(value) => value.trim().to_string(),
        Value::Number(value) => value.to_string(),
        _ => return None,
    };

    let digits = raw.strip_prefix("<@").unwrap_or(&raw);
    let digits = digits.strip_prefix('!').unwrap_or(digits);
    let digits = digits.strip_suffix('>').unwrap_or(digits);

    digits
        .parse::<u64>()
        .ok()
        .filter(|id| *id != 0)
        .map(Id::new)
}

fn is_valid_nickname(nickname: &str) -> bool {
    nickname.chars().count() <= MAX_NICKNAME_LENGTH
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn parses_plain_ids() {
        assert_eq!(
            parse_user_id(&json!({ "user_id": "123" })),
            Some(Id::new(123))
        );
        assert_eq!(
            parse_user_id(&json!({ "user_id": 123 })),
            Some(Id::new(123))
        );
    }

    #[test]
    fn parses_mentions() {
        assert_eq!(
            parse_user_id(&json!({ "user_id": "<@123>" })),
            Some(Id::new(123))
        );
        assert_eq!(
            parse_user_id(&json!({ "user_id": "<@!123>" })),
            Some(Id::new(123))
        );
    }

    #[test]
    fn rejects_invalid_ids() {
        assert_eq!(parse_user_id(&json!({})), None);
        assert_eq!(parse_user_id(&json!({ "user_id": "abc" })), None);
        assert_eq!(parse_user_id(&json!({ "user_id": "" })), None);
        assert_eq!(parse_user_id(&json!({ "user_id": 0 })), None);
        assert_eq!(parse_user_id(&json!({ "user_id": true })), None);
    }

    #[test]
    fn nickname_length_is_capped() {
        assert!(is_valid_nickname(""));
        assert!(is_valid_nickname("Cuby"));
        assert!(is_valid_nickname(&"a".repeat(MAX_NICKNAME_LENGTH)));
        assert!(!is_valid_nickname(&"a".repeat(MAX_NICKNAME_LENGTH + 1)));
    }
}
