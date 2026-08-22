use twilight_model::user::User;

const BASE_ASSET_URI: &str = "https://cdn.discordapp.com";

pub fn format_avatar_url(user: &User, format: &str, size: u16) -> Option<String> {
    user.avatar.as_ref().map(|avatar_hash| {
        format!(
            "{}/avatars/{}/{}.{}?size={}",
            BASE_ASSET_URI, user.id, avatar_hash, format, size
        )
    })
}
