use crate::interactions::InteractionHandler;

mod nickname;
mod pet;
mod remind;
mod server_shuffle;

pub fn get_chat_input_interaction_handlers() -> Vec<Box<dyn InteractionHandler + Send + Sync>> {
    vec![
        Box::new(nickname::NicknameChatInputCommandHandler),
        Box::new(pet::PetChatInputCommandHandler),
        Box::new(remind::RemindChatInputCommandHandler),
        Box::new(server_shuffle::ServerShuffleChatInputCommandHandler::new()),
    ]
}
