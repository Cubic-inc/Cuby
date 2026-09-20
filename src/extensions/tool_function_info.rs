use ollama_rs::generation::tools::{ToolFunctionInfo, ToolInfo, ToolType};

pub trait ToolFunctionInfoExt {
    fn into_tool_info(self) -> ToolInfo;
}

impl ToolFunctionInfoExt for ToolFunctionInfo {
    fn into_tool_info(self) -> ToolInfo {
        ToolInfo {
            tool_type: ToolType::Function,
            function: self,
        }
    }
}
