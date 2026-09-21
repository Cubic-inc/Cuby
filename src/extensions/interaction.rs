use twilight_model::application::interaction::{
    Interaction, InteractionData,
    application_command::CommandData,
};

pub trait InteractionExt {
    fn command_data(&self) -> Option<&CommandData>;
}

impl InteractionExt for Interaction {
    fn command_data(&self) -> Option<&CommandData> {
        match &self.data {
            Some(InteractionData::ApplicationCommand(data)) => Some(data),
            _ => None,
        }
    }
}
