use twilight_model::{
    channel::Message,
    id::{Id, marker::UserMarker},
};

pub trait MessageExt {
    fn mentions_user(&self, user_id: Id<UserMarker>) -> bool;
}

impl MessageExt for Message {
    fn mentions_user(&self, user_id: Id<UserMarker>) -> bool {
        self.mentions.iter().any(|mention| mention.id == user_id)
    }
}
