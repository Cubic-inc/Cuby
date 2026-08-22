use crate::interactions::InteractionHandler;

pub mod primary;

pub fn get_entry_point_interaction_handlers() -> Vec<Box<dyn InteractionHandler + Send + Sync>> {
    vec![Box::new(primary::PrimaryEntryPointInteractionHandler)]
}
