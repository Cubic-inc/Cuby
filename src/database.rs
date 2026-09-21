use rusqlite::Connection;

pub type Migration = &'static str;

fn get_user_version(db: &Connection) -> i32 {
    db.query_row("PRAGMA user_version", [], |row| row.get(0))
        .unwrap_or(0)
}

fn set_user_version(db: &Connection, version: i32) -> Result<(), rusqlite::Error> {
    db.execute(&format!("PRAGMA user_version = {}", version), [])
        .map(|_| ())
}

pub fn execute_migrations(db: &Connection, migrations: &[Migration]) {
    let current_version = get_user_version(db);
    for (i, migration) in migrations.iter().enumerate() {
        let migration_version = (i + 1) as i32;
        if migration_version <= current_version {
            continue;
        }
        tracing::info!("Applying migration {}", migration_version);
        db.execute(migration, []).unwrap_or_else(|e| {
            panic!(
                "Migration {} failed: {e}\nQuery: {migration}",
                migration_version
            )
        });
        set_user_version(db, migration_version).expect("Failed to update database version");
    }
    tracing::info!(
        "Database migrations completed. Current version: {}",
        get_user_version(db)
    );
}
