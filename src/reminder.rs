use std::{sync::Arc, time::Duration};

use chrono::{DateTime, TimeDelta, Utc};
use rusqlite::Connection;
use tokio::{sync::Mutex, task::AbortHandle};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(i64)]
pub enum RemindLocation {
    Dm = 1,
    Channel = 2,
}

impl From<RemindLocation> for i64 {
    fn from(loc: RemindLocation) -> Self {
        loc as i64
    }
}

impl TryFrom<i64> for RemindLocation {
    type Error = i64;

    fn try_from(value: i64) -> Result<Self, Self::Error> {
        match value {
            1 => Ok(RemindLocation::Dm),
            2 => Ok(RemindLocation::Channel),
            _ => Err(value),
        }
    }
}

#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct Reminder {
    pub id: i64,
    pub created_for_id: i64,
    pub created_by_id: i64,
    pub created_at: DateTime<Utc>,
    pub remind_at: DateTime<Utc>,
    pub remind_message: Option<String>,
    pub remind_location: RemindLocation,
    pub source_guild_id: i64,
    pub source_channel_id: i64,
    pub source_message_id: i64,
}

pub struct ReminderManager {
    database: Arc<Mutex<Connection>>,
    event_sender: tokio::sync::mpsc::Sender<Reminder>,
    event_receiver: Option<tokio::sync::mpsc::Receiver<Reminder>>,
    current_timer: Mutex<Option<AbortHandle>>,
}

impl ReminderManager {
    pub fn new(database: Arc<Mutex<Connection>>) -> Self {
        let (event_sender, event_receiver) = tokio::sync::mpsc::channel(100);

        Self {
            database,
            event_sender,
            event_receiver: Some(event_receiver),
            current_timer: Mutex::new(None),
        }
    }

    pub fn take_event_receiver(&mut self) -> tokio::sync::mpsc::Receiver<Reminder> {
        self.event_receiver
            .take()
            .expect("Can not take event receiver twice.")
    }

    pub async fn schedule_next(&self) {
        // Abort the current timer if one exists
        if let Some(abort_handle) = self.current_timer.lock().await.take() {
            abort_handle.abort();
        }

        // Fetch the next pending reminder, releasing the DB lock before any sleep
        let next = match self.get_next_pending().await {
            Ok(Some(reminder)) => reminder,
            _ => return,
        };

        let now = Utc::now();
        let sleep_duration = if next.remind_at > now {
            (next.remind_at - now)
                .to_std()
                .unwrap_or(Duration::from_secs(1))
        } else {
            Duration::from_secs(0)
        };

        let sender = self.event_sender.clone();

        let handle = tokio::spawn(async move {
            tokio::time::sleep(sleep_duration).await;
            let _ = sender.send(next).await;
        });

        *self.current_timer.lock().await = Some(handle.abort_handle());
    }

    pub async fn create(
        &self,
        created_for_id: i64,
        created_by_id: i64,
        remind_message: Option<&str>,
        remind_at: DateTime<Utc>,
        remind_location: RemindLocation,
        source_guild_id: i64,
        source_channel_id: i64,
        source_message_id: i64,
    ) -> Result<Reminder, rusqlite::Error> {
        let db = self.database.lock().await;
        let now = Utc::now();
        let location_i64: i64 = remind_location.into();
        db.execute(
            "INSERT INTO reminders (created_for_id, created_by_id, created_at, remind_at, remind_message, remind_location, source_guild_id, source_channel_id, source_message_id) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            rusqlite::params![created_for_id, created_by_id, now.to_rfc3339(), remind_at.to_rfc3339(), remind_message, location_i64, source_guild_id, source_channel_id, source_message_id],
        )?;
        let id = db.last_insert_rowid();
        let reminder = Reminder {
            id,
            created_for_id,
            created_by_id,
            created_at: now,
            remind_at,
            remind_message: remind_message.map(|s| s.to_string()),
            remind_location,
            source_guild_id,
            source_channel_id,
            source_message_id,
        };
        drop(db);

        self.schedule_next().await;

        Ok(reminder)
    }

    async fn get_next_pending(&self) -> Result<Option<Reminder>, rusqlite::Error> {
        let db = self.database.lock().await;
        let now = Utc::now().to_rfc3339();
        let mut stmt = db.prepare(
            "SELECT id, created_for_id, created_by_id, created_at, remind_at, remind_message, remind_location, source_guild_id, source_channel_id, source_message_id FROM reminders WHERE remind_at IS NOT NULL AND remind_at > ?1 ORDER BY remind_at ASC LIMIT 1",
        )?;
        let mut rows = stmt.query_map(rusqlite::params![now], |row| {
            Ok(Reminder {
                id: row.get(0)?,
                created_for_id: row.get(1)?,
                created_by_id: row.get(2)?,
                created_at: DateTime::parse_from_rfc3339(&row.get::<_, String>(3)?)
                    .unwrap_or_default()
                    .with_timezone(&Utc),
                remind_at: DateTime::parse_from_rfc3339(&row.get::<_, String>(4)?)
                    .unwrap_or_default()
                    .with_timezone(&Utc),
                remind_message: row.get(5)?,
                remind_location: RemindLocation::try_from(row.get::<_, i64>(6)?)
                    .unwrap_or(RemindLocation::Channel),
                source_guild_id: row.get(7)?,
                source_channel_id: row.get(8)?,
                source_message_id: row.get(9)?,
            })
        })?;
        rows.next().transpose()
    }

    pub async fn delete(&self, id: i64) -> Result<bool, rusqlite::Error> {
        let db = self.database.lock().await;
        let affected = db.execute("DELETE FROM reminders WHERE id = ?1", rusqlite::params![id])?;
        drop(db);

        self.schedule_next().await;

        Ok(affected > 0)
    }
}

pub fn compute_remind_at(
    seconds: Option<i64>,
    minutes: Option<i64>,
    hours: Option<i64>,
    days: Option<i64>,
    weeks: Option<i64>,
    months: Option<i64>,
    years: Option<i64>,
) -> Option<DateTime<Utc>> {
    let mut delta = TimeDelta::default();
    delta = delta + TimeDelta::seconds(seconds.unwrap_or(0));
    delta = delta + TimeDelta::minutes(minutes.unwrap_or(0));
    delta = delta + TimeDelta::hours(hours.unwrap_or(0));
    delta = delta + TimeDelta::days(days.unwrap_or(0));
    delta = delta + TimeDelta::weeks(weeks.unwrap_or(0));
    delta = delta + TimeDelta::days(months.unwrap_or(0) * 30);
    delta = delta + TimeDelta::days(years.unwrap_or(0) * 365);

    if delta <= TimeDelta::zero() {
        return None;
    }

    Some(Utc::now() + delta)
}

pub fn format_duration(
    seconds: Option<i64>,
    minutes: Option<i64>,
    hours: Option<i64>,
    days: Option<i64>,
    weeks: Option<i64>,
    months: Option<i64>,
    years: Option<i64>,
) -> String {
    let mut parts = Vec::new();
    if let Some(v) = years {
        if v > 0 {
            parts.push(format!("{} year{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = months {
        if v > 0 {
            parts.push(format!("{} month{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = weeks {
        if v > 0 {
            parts.push(format!("{} week{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = days {
        if v > 0 {
            parts.push(format!("{} day{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = hours {
        if v > 0 {
            parts.push(format!("{} hour{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = minutes {
        if v > 0 {
            parts.push(format!("{} minute{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    if let Some(v) = seconds {
        if v > 0 {
            parts.push(format!("{} second{}", v, if v == 1 { "" } else { "s" }));
        }
    }
    parts.join(", ")
}
