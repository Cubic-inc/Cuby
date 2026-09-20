use ollama_rs::generation::tools::ToolInfo;

use crate::State;

#[allow(dead_code)]
pub trait Tool {
    fn info(&self) -> ToolInfo;
    fn execute(&self, state: State) -> String;
}
