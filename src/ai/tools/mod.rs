use ollama_rs::generation::tools::ToolInfo;
use serde_json::Value;
use twilight_model::channel::Message;

use crate::State;

mod reminder;

#[allow(dead_code)]
#[async_trait::async_trait]
pub trait Tool: Send + Sync {
    fn info(&self) -> ToolInfo;
    async fn execute(&self, state: State, arguments: Value) -> String;
    async fn post_execute(&self, _state: State, _message: &Message, _arguments: Value) {}
}

pub fn get_tools() -> Vec<Box<dyn Tool>> {
    vec![Box::new(reminder::ReminderTool)]
}
