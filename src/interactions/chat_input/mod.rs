use crate::interactions::InteractionHandler;

pub mod pet;

pub fn get_chat_input_interaction_handlers() -> Vec<Box<dyn InteractionHandler + Send + Sync>> {
    vec![Box::new(pet::PetChatInputCommandHandler)]
}
