CREATE TABLE reminders (
    -- Unique id of the reminder
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Who is the reminder for
    created_for_id INTEGER NOT NULL,
    -- Who created the reminder
    created_by_id INTEGER NOT NULL,

    -- When the reminder was created
    created_at DATETIME NOT NULL,
    -- When the reminder should be sent
    remind_at DATETIME NOT NULL,
    -- The message of the reminder
    remind_message TEXT,
    -- Where should the reminder be sent, 1 = DM, 2 = Channel
    remind_location INTEGER NOT NULL,

    -- Where was the reminder created
    source_guild_id INTEGER NOT NULL,
    source_channel_id INTEGER NOT NULL,
    source_message_id INTEGER NOT NULL
);
