use twilight_model::http::interaction::{
    InteractionResponse, InteractionResponseData, InteractionResponseType,
};

pub trait InteractionResponseDataExt {
    fn into_channel_message_with_source(self) -> InteractionResponse;
}

impl InteractionResponseDataExt for InteractionResponseData {
    fn into_channel_message_with_source(self) -> InteractionResponse {
        InteractionResponse {
            kind: InteractionResponseType::ChannelMessageWithSource,
            data: Some(self),
        }
    }
}
