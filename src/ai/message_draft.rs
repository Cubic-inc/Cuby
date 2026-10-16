use twilight_model::http::attachment::Attachment;

/// Collects the effects tools want to apply to the reply that is sent once the
/// model has finished talking.
///
/// The real [`twilight_http`] `CreateMessage` builder cannot be held while the
/// tools run: its mutators consume `self` and borrow their arguments for the
/// builder's whole lifetime, so data created during tool execution (like an
/// image we just downloaded) could never be attached. Instead tools queue
/// attachments here and the builder is constructed from the draft in one go,
/// right before it is sent.
#[derive(Debug, Default)]
pub struct MessageDraft {
    attachments: Vec<Attachment>,
}

impl MessageDraft {
    pub fn new() -> Self {
        Self::default()
    }

    /// Queue a file to upload alongside the reply. Attachment ids only need to
    /// be unique within a single message, so they are assigned here.
    pub fn attach(&mut self, filename: impl Into<String>, bytes: Vec<u8>) {
        let id = self.attachments.len() as u64 + 1;
        self.attachments
            .push(Attachment::from_bytes(filename.into(), bytes, id));
    }

    pub fn attachments(&self) -> &[Attachment] {
        &self.attachments
    }
}
