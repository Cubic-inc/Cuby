use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use reqwest::Url;
use serde::Deserialize;

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::{MessageDraft, Tool};

const BASE_URL: &str = "https://memegen.rs";
/// Discord's default upload limit is 10 MiB; keep a little headroom.
const MAX_IMAGE_BYTES: usize = 8 * 1024 * 1024;
const MAX_DIMENSION: i64 = 2048;

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
                    },
                    "style": {
                        "type": "string",
                        "description": "Optional alternate background variant. Omit to use the template's default style."
                    },
                    "layout": {
                        "type": "string",
                        "description": "Optional. Set to top to place every caption at the top instead of spreading them out."
                    },
                    "color": {
                        "type": "string",
                        "description": "Optional caption text color, a name or a hex value like #ff0000."
                    },
                    "width": {
                        "type": "integer",
                        "description": "Optional width to pad the image to. Must be used together with height."
                    },
                    "height": {
                        "type": "integer",
                        "description": "Optional height to pad the image to. Must be used together with width."
                    },
                    "background": {
                        "type": "string",
                        "description": "Optional URL of a custom background image (PNG, JPEG, GIF or WebP) to caption instead of using a template."
                    },
                    "format": {
                        "type": "string",
                        "description": "Optional output format, png (default) or gif for animated templates."
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

        let ext = match normalize_format(string_argument(&arguments, "format").as_deref()) {
            Ok(ext) => ext,
            Err(e) => return format!("Error: {}", e),
        };

        let options = MemeOptions {
            style: string_argument(&arguments, "style"),
            layout: string_argument(&arguments, "layout"),
            color: string_argument(&arguments, "color"),
            width: integer_argument(&arguments, "width"),
            height: integer_argument(&arguments, "height"),
            background: string_argument(&arguments, "background"),
        };
        if let Err(e) = options.validate() {
            return format!("Error: {}", e);
        }

        let url = build_url(&template, &lines, ext, &options);

        match fetch_meme(&url).await {
            Ok((bytes, content_type)) => {
                let filename_ext =
                    extension_for_content_type(content_type.as_deref()).unwrap_or(ext);
                draft.attach(format!("meme.{}", filename_ext), bytes);
                "The meme has been generated and attached to your reply. Do not mention or link the \
                 image URL, just describe the meme in your own words if you want to."
                    .to_string()
            }
            Err(e) => format!("Error: {}", e),
        }
    }
}

#[derive(Default, Clone)]
pub(super) struct MemeOptions {
    pub style: Option<String>,
    pub layout: Option<String>,
    pub color: Option<String>,
    pub width: Option<i64>,
    pub height: Option<i64>,
    pub background: Option<String>,
}

impl MemeOptions {
    fn validate(&self) -> Result<(), String> {
        match (self.width, self.height) {
            (Some(_), None) | (None, Some(_)) => {
                return Err("width and height must be provided together.".to_string());
            }
            _ => {}
        }

        if self
            .width
            .is_some_and(|w| !(0..=MAX_DIMENSION).contains(&w))
        {
            return Err(format!("width must be between 0 and {}.", MAX_DIMENSION));
        }
        if self
            .height
            .is_some_and(|h| !(0..=MAX_DIMENSION).contains(&h))
        {
            return Err(format!("height must be between 0 and {}.", MAX_DIMENSION));
        }

        Ok(())
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

/// Builds the image URL for a template (or a custom background) with captions
/// and any options applied.
pub(super) fn build_url(
    template: &str,
    lines: &[String],
    ext: &str,
    options: &MemeOptions,
) -> String {
    let encoded = encode_lines(lines);

    let path = if options.background.is_some() {
        let text = if encoded.is_empty() {
            "_"
        } else {
            encoded.as_str()
        };
        format!("{}/images/custom/{}.{}", BASE_URL, text, ext)
    } else if encoded.is_empty() {
        format!("{}/images/{}.{}", BASE_URL, template, ext)
    } else {
        format!("{}/images/{}/{}.{}", BASE_URL, template, encoded, ext)
    };

    // `Url` handles percent-encoding for values like `#ff0000` in `color`.
    // Only touch the query when there is something to add, otherwise the
    // builder would leave a dangling `?`.
    let Ok(mut url) = Url::parse(&path) else {
        return path;
    };

    let has_options = options.style.is_some()
        || options.layout.is_some()
        || options.color.is_some()
        || options.width.is_some()
        || options.height.is_some()
        || options.background.is_some();

    if has_options {
        let mut query = url.query_pairs_mut();
        if let Some(style) = &options.style {
            query.append_pair("style", style);
        }
        if let Some(layout) = &options.layout {
            query.append_pair("layout", layout);
        }
        if let Some(color) = &options.color {
            query.append_pair("color", color);
        }
        if let Some(width) = options.width {
            query.append_pair("width", &width.to_string());
        }
        if let Some(height) = options.height {
            query.append_pair("height", &height.to_string());
        }
        if let Some(background) = &options.background {
            query.append_pair("background", background);
        }
    }

    url.into()
}

fn normalize_format(format: Option<&str>) -> Result<&'static str, String> {
    match format.unwrap_or("png").to_ascii_lowercase().as_str() {
        "png" => Ok("png"),
        "gif" => Ok("gif"),
        "jpg" | "jpeg" => Ok("jpg"),
        "webp" => Ok("webp"),
        other => Err(format!(
            "'{}' is not a supported format, use png, gif, jpg or webp.",
            other
        )),
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

fn integer_argument(arguments: &serde_json::Value, name: &str) -> Option<i64> {
    arguments.get(name).and_then(|value| value.as_i64())
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
        let url = build_url(
            "drake",
            &lines(&["top line", "bottom line"]),
            "png",
            &MemeOptions::default(),
        );
        assert_eq!(
            url,
            "https://memegen.rs/images/drake/top_line/bottom_line.png"
        );
    }

    #[test]
    fn builds_blank_template_url() {
        let url = build_url("drake", &[], "gif", &MemeOptions::default());
        assert_eq!(url, "https://memegen.rs/images/drake.gif");
    }

    #[test]
    fn builds_options_and_custom_background() {
        let options = MemeOptions {
            layout: Some("top".to_string()),
            color: Some("#ff0000".to_string()),
            width: Some(600),
            height: Some(400),
            background: Some("https://example.com/photo.jpg".to_string()),
            ..MemeOptions::default()
        };
        let url = build_url("custom", &lines(&["hello world"]), "png", &options);

        assert!(url.starts_with("https://memegen.rs/images/custom/hello_world.png?"));
        assert!(url.contains("layout=top"));
        assert!(url.contains("color=%23ff0000"));
        assert!(url.contains("width=600"));
        assert!(url.contains("height=400"));
        assert!(url.contains("background=https%3A%2F%2Fexample.com%2Fphoto.jpg"));
    }

    #[test]
    fn custom_background_without_lines_uses_blank_segment() {
        let options = MemeOptions {
            background: Some("https://example.com/photo.jpg".to_string()),
            ..MemeOptions::default()
        };
        let url = build_url("custom", &[], "png", &options);
        assert!(url.starts_with("https://memegen.rs/images/custom/_.png?"));
    }

    #[test]
    fn width_and_height_must_pair() {
        let only_width = MemeOptions {
            width: Some(100),
            ..MemeOptions::default()
        };
        assert!(only_width.validate().is_err());

        let both = MemeOptions {
            width: Some(100),
            height: Some(100),
            ..MemeOptions::default()
        };
        assert!(both.validate().is_ok());
    }

    #[test]
    fn rejects_oversized_dimensions() {
        let too_wide = MemeOptions {
            width: Some(4000),
            height: Some(4000),
            ..MemeOptions::default()
        };
        assert!(too_wide.validate().is_err());
    }

    #[test]
    fn format_aliases() {
        assert_eq!(normalize_format(None), Ok("png"));
        assert_eq!(normalize_format(Some("GIF")), Ok("gif"));
        assert_eq!(normalize_format(Some("jpeg")), Ok("jpg"));
        assert!(normalize_format(Some("bmp")).is_err());
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
