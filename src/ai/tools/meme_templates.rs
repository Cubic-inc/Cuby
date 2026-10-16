use ollama_rs::{generation::tools::ToolFunctionInfo, re_exports::schemars::json_schema};
use serde::Deserialize;
use twilight_model::channel::Message;

use crate::{State, extensions::tool_function_info::ToolFunctionInfoExt};

use super::{MessageDraft, Tool};

const TEMPLATES_URL: &str = "https://memegen.rs/templates";
/// Enough options to be useful without flooding the model's context.
const MAX_RESULTS: usize = 10;

pub struct MemeTemplatesTool;

#[async_trait::async_trait]
impl Tool for MemeTemplatesTool {
    fn info(&self) -> ollama_rs::generation::tools::ToolInfo {
        ToolFunctionInfo {
            name: "list_meme_templates".to_string(),
            description: "Lists or searches the available memegen.rs meme templates so you can pick \
                 the right template id for generate_meme. Writes a short list of matching templates \
                 with their id, name and how many caption lines they take."
                .to_string(),
            parameters: json_schema!({
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Optional search text matched against template ids, names, aliases and keywords, for example drake or confused. Omit to list the most popular templates."
                    }
                },
                "required": []
            }),
        }
        .into_tool_info()
    }

    async fn execute(
        &self,
        _state: State,
        _message: &Message,
        _draft: &mut MessageDraft,
        arguments: serde_json::Value,
    ) -> String {
        let query = arguments
            .get("query")
            .and_then(|value| value.as_str())
            .map(str::trim)
            .filter(|query| !query.is_empty());

        let templates = match fetch_templates().await {
            Ok(templates) => templates,
            Err(e) => return format!("Error: {}", e),
        };

        let matches = matching_templates(&templates, query);
        format_templates(&matches, query)
    }
}

#[derive(Debug, Clone, Deserialize)]
pub(super) struct Template {
    pub id: String,
    pub name: String,
    pub lines: u32,
    #[serde(default)]
    pub keywords: Vec<String>,
    #[serde(default)]
    pub aliases: Vec<String>,
}

pub(super) fn matching_templates<'a>(
    templates: &'a [Template],
    query: Option<&str>,
) -> Vec<&'a Template> {
    let Some(query) = query else {
        return templates.iter().take(MAX_RESULTS).collect();
    };

    let query = query.to_ascii_lowercase();
    templates
        .iter()
        .filter(|template| matches_template(template, &query))
        .take(MAX_RESULTS)
        .collect()
}

fn matches_template(template: &Template, query: &str) -> bool {
    template.id.to_ascii_lowercase().contains(query)
        || template.name.to_ascii_lowercase().contains(query)
        || template
            .keywords
            .iter()
            .any(|keyword| keyword.to_ascii_lowercase().contains(query))
        || template
            .aliases
            .iter()
            .any(|alias| alias.to_ascii_lowercase().contains(query))
}

pub(super) fn format_templates(templates: &[&Template], query: Option<&str>) -> String {
    if templates.is_empty() {
        return match query {
            Some(query) => format!("No meme templates matched '{}'.", query),
            None => "No meme templates are available right now.".to_string(),
        };
    }

    let header = match query {
        Some(query) => format!("Meme templates matching '{}':", query),
        None => "Popular meme templates:".to_string(),
    };

    let items = templates
        .iter()
        .map(|template| {
            format!(
                "- {} ({}) - {} caption line{}",
                template.id,
                template.name,
                template.lines,
                if template.lines == 1 { "" } else { "s" }
            )
        })
        .collect::<Vec<_>>()
        .join("\n");

    format!("{}\n{}", header, items)
}

async fn fetch_templates() -> Result<Vec<Template>, String> {
    let response = reqwest::get(TEMPLATES_URL)
        .await
        .map_err(|e| format!("could not reach memegen: {}", e))?;

    if !response.status().is_success() {
        return Err(format!(
            "memegen returned an error while listing templates ({})",
            response.status()
        ));
    }

    let body = response
        .text()
        .await
        .map_err(|e| format!("could not read the template list: {}", e))?;

    serde_json::from_str(&body).map_err(|e| format!("could not parse the template list: {}", e))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fixtures() -> Vec<Template> {
        serde_json::from_str(
            r#"[
                {"id":"drake-hotline-bling","name":"Drake Hotline Bling","lines":2,
                 "keywords":["drake","no","yes"],"aliases":["drake-blank"]},
                {"id":"two-buttons","name":"Two Buttons","lines":3,
                 "keywords":["daily struggle"],"aliases":["ds"]},
                {"id":"distracted-boyfriend","name":"Distracted Boyfriend","lines":3,
                 "keywords":["distracted"],"aliases":["db"]}
            ]"#,
        )
        .unwrap()
    }

    #[test]
    fn lists_all_without_query() {
        let templates = fixtures();
        let matches = matching_templates(&templates, None);
        assert_eq!(matches.len(), 3);
    }

    #[test]
    fn matches_id_name_keywords_and_aliases() {
        let templates = fixtures();

        let by_name = matching_templates(&templates, Some("two buttons"));
        assert_eq!(by_name.len(), 1);
        assert_eq!(by_name[0].id, "two-buttons");

        let by_alias = matching_templates(&templates, Some("ds"));
        assert_eq!(by_alias.len(), 1);
        assert_eq!(by_alias[0].id, "two-buttons");

        let by_keyword = matching_templates(&templates, Some("drake"));
        assert_eq!(by_keyword.len(), 1);
        assert_eq!(by_keyword[0].id, "drake-hotline-bling");
    }

    #[test]
    fn formats_hits_and_misses() {
        let templates = fixtures();

        let found = matching_templates(&templates, Some("drake"));
        let text = format_templates(&found, Some("drake"));
        assert!(text.starts_with("Meme templates matching 'drake':"));
        assert!(text.contains("drake-hotline-bling"));
        assert!(text.contains("2 caption lines"));

        let missing = matching_templates(&templates, Some("nonsense"));
        assert_eq!(
            format_templates(&missing, Some("nonsense")),
            "No meme templates matched 'nonsense'."
        );
    }
}
