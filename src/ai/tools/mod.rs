use ollama_rs::generation::tools::ToolInfo;
use serde_json::Value;
use twilight_model::channel::Message;

use crate::State;

mod calculate;
mod generate_memes;
mod meme_templates;
mod random_number;
mod reminder;
mod rename_user;

pub use crate::ai::message_draft::MessageDraft;

#[allow(dead_code)]
#[async_trait::async_trait]
pub trait Tool: Send + Sync {
    fn info(&self) -> ToolInfo;
    async fn execute(
        &self,
        state: State,
        message: &Message,
        draft: &mut MessageDraft,
        arguments: Value,
    ) -> String;
    async fn post_execute(&self, _state: State, _message: &Message, _arguments: Value) {}
}

pub fn get_tools() -> Vec<Box<dyn Tool>> {
    vec![
        Box::new(reminder::ReminderTool),
        Box::new(calculate::CalculateTool),
        Box::new(random_number::RandomNumberTool),
        Box::new(generate_memes::MemeTool),
        Box::new(meme_templates::MemeTemplatesTool),
        Box::new(rename_user::RenameUserTool),
    ]
}
