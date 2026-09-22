use twilight_model::{
    application::interaction::application_command::{CommandData, CommandOptionValue},
    id::{Id, marker::UserMarker},
};

pub trait CommandDataExt {
    fn get_string(&self, name: &str) -> Option<&str>;
    fn get_integer(&self, name: &str) -> Option<i64>;
    fn get_user(&self, name: &str) -> Option<Id<UserMarker>>;
}

impl CommandDataExt for CommandData {
    fn get_string(&self, name: &str) -> Option<&str> {
        self.options.iter().find_map(|o| {
            if o.name == name {
                if let CommandOptionValue::String(s) = &o.value {
                    return Some(s.as_str());
                }
            }
            None
        })
    }

    fn get_integer(&self, name: &str) -> Option<i64> {
        self.options.iter().find_map(|o| {
            if o.name == name {
                if let CommandOptionValue::Integer(i) = &o.value {
                    return Some(*i);
                }
            }
            None
        })
    }

    fn get_user(&self, name: &str) -> Option<Id<UserMarker>> {
        self.options.iter().find_map(|o| {
            if o.name == name {
                if let CommandOptionValue::User(id) = &o.value {
                    return Some(*id);
                }
            }
            None
        })
    }
}
