use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use serde::Deserialize;
use twilight_model::channel::Message;

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::{MessageDraft, Tool};

const BASE_URL: &str = "https://memegen.rs";
/// Discord's default upload limit is 10 MiB; keep a little headroom.
const MAX_IMAGE_BYTES: usize = 8 * 1024 * 1024;

pub struct MemeTool;

#[async_trait::async_trait]
impl Tool for MemeTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "generate_meme".to_string(),
            description: "Generates a meme image from the memegen.rs template library and attaches \
                 it to your reply. The image is uploaded to Discord for you, so never write a link \
                 or URL in your response when you use this. Provide a template id and one caption \
                 line per image row. Use list_meme_templates if you are unsure which template fits."
                .to_string(),
            parameters: json_schema!({
                "type": "object",
                "properties": {
                    "template": {
                        "type": "string",
                        "description": "Template id or alias, for example drake, two-buttons or distracted-boyfriend."
                    },
                    "lines": {
                        "type": "array",
                        "items": { "type": "string" },
                        "description": "One caption per line, in order from top to bottom. Use an empty string for a blank line. Match the number of lines the template expects."
                    }
                },
                "required": ["template", "lines"]
            }),
        }
        .into_tool_info()
    }

    async fn execute(
        &self,
        _state: State,
        _message: &Message,
        draft: &mut MessageDraft,
        arguments: serde_json::Value,
    ) -> String {
        let Some(template) = string_argument(&arguments, "template") else {
            return "Error: missing required argument template.".to_string();
        };
        if !is_valid_template(&template) {
            return format!("Error: '{}' is not a valid meme template id.", template);
        }

        let lines = lines_argument(&arguments);

        let url = build_url(&template, &lines);

        match fetch_meme(&url).await {
            Ok((bytes, content_type)) => {
                let filename_ext =
                    extension_for_content_type(content_type.as_deref()).unwrap_or("png");
                draft.attach(format!("meme.{}", filename_ext), bytes);
                "The meme has been generated and attached to your reply. Do not mention or link the \
                 image URL, just describe the meme in your own words if you want to."
                    .to_string()
            }
            Err(e) => format!("Error: {}", e),
        }
    }
}

/// Encodes a single caption line the way memegen.rs expects, so the slug can
/// safely travel as a path segment (see memegen-rs' own encoder).
pub(super) fn encode_line(line: &str) -> String {
    if line.is_empty() {
        return "_".to_string();
    }

    line.replace('_', "__")
        .replace(' ', "_")
        .replace('?', "~q")
        .replace('&', "~a")
        .replace('%', "~p")
        .replace('#', "~h")
        .replace('/', "~s")
        .replace('"', "''")
}

pub(super) fn encode_lines(lines: &[String]) -> String {
    lines
        .iter()
        .map(|line| encode_line(line))
        .collect::<Vec<_>>()
        .join("/")
}

/// Builds the image URL for a template with captions.
pub(super) fn build_url(template: &str, lines: &[String]) -> String {
    let encoded = encode_lines(lines);

    if encoded.is_empty() {
        format!("{}/images/{}.png", BASE_URL, template)
    } else {
        format!("{}/images/{}/{}.png", BASE_URL, template, encoded)
    }
}

fn extension_for_content_type(content_type: Option<&str>) -> Option<&'static str> {
    let content_type = content_type?.split(';').next()?.trim();
    match content_type {
        "image/png" => Some("png"),
        "image/gif" => Some("gif"),
        "image/jpeg" => Some("jpg"),
        "image/webp" => Some("webp"),
        _ => None,
    }
}

fn is_valid_template(template: &str) -> bool {
    !template.is_empty()
        && template.len() <= 100
        && template
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_')
}

fn string_argument(arguments: &serde_json::Value, name: &str) -> Option<String> {
    arguments
        .get(name)
        .and_then(|value| value.as_str())
        .filter(|value| !value.is_empty())
        .map(str::to_string)
}

fn lines_argument(arguments: &serde_json::Value) -> Vec<String> {
    arguments
        .get("lines")
        .and_then(|value| value.as_array())
        .map(|lines| {
            lines
                .iter()
                .filter_map(|line| line.as_str())
                .map(str::to_string)
                .collect()
        })
        .unwrap_or_default()
}

#[derive(Debug, Deserialize)]
struct MemeError {
    error: String,
}

async fn fetch_meme(url: &str) -> Result<(Vec<u8>, Option<String>), String> {
    let response = reqwest::get(url)
        .await
        .map_err(|e| format!("could not reach memegen: {}", e))?;

    let status = response.status();
    let content_type = response
        .headers()
        .get(reqwest::header::CONTENT_TYPE)
        .and_then(|value| value.to_str().ok())
        .map(str::to_string);

    if !status.is_success() {
        let body = response.text().await.unwrap_or_default();
        let message = serde_json::from_str::<MemeError>(&body)
            .map(|error| error.error)
            .unwrap_or_else(|_| body.trim().to_string());
        return Err(if message.is_empty() {
            format!("memegen returned an error ({})", status)
        } else {
            message
        });
    }

    if let Some(content_type) = content_type.as_deref()
        && !content_type.starts_with("image/")
    {
        return Err(format!(
            "memegen returned an unexpected content type: {}",
            content_type
        ));
    }

    let bytes = response
        .bytes()
        .await
        .map_err(|e| format!("could not read the meme image: {}", e))?;

    if bytes.len() > MAX_IMAGE_BYTES {
        return Err("the generated meme is too large to upload.".to_string());
    }

    Ok((bytes.to_vec(), content_type))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lines(values: &[&str]) -> Vec<String> {
        values.iter().map(|value| value.to_string()).collect()
    }

    #[test]
    fn encodes_spaces_and_underscores() {
        assert_eq!(encode_line("hello world"), "hello_world");
        assert_eq!(encode_line("a_b"), "a__b");
        assert_eq!(encode_line(""), "_");
        assert_eq!(encode_line("one two_three"), "one_two__three");
    }

    #[test]
    fn encodes_reserved_characters() {
        assert_eq!(encode_line("50% & more"), "50~p_~a_more");
        assert_eq!(encode_line("a/b #1"), "a~sb_~h1");
        assert_eq!(
            encode_line("for the better, right?"),
            "for_the_better,_right~q"
        );
        assert_eq!(encode_line("say \"hi\""), "say_''hi''");
    }

    #[test]
    fn builds_template_urls() {
        let url = build_url("drake", &lines(&["top line", "bottom line"]));
        assert_eq!(
            url,
            "https://memegen.rs/images/drake/top_line/bottom_line.png"
        );
    }

    #[test]
    fn builds_blank_template_url() {
        let url = build_url("drake", &[]);
        assert_eq!(url, "https://memegen.rs/images/drake.png");
    }

    #[test]
    fn content_type_extensions() {
        assert_eq!(extension_for_content_type(Some("image/png")), Some("png"));
        assert_eq!(
            extension_for_content_type(Some("image/gif; charset=utf-8")),
            Some("gif")
        );
        assert_eq!(extension_for_content_type(Some("application/json")), None);
        assert_eq!(extension_for_content_type(None), None);
    }

    #[test]
    fn template_ids_are_validated() {
        assert!(is_valid_template("drake"));
        assert!(is_valid_template("two-buttons"));
        assert!(!is_valid_template(""));
        assert!(!is_valid_template("../etc/passwd"));
        assert!(!is_valid_template("drake/../../x"));
    }
}
