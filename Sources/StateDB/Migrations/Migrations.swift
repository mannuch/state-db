//
//  Migrations.swift
//  
//
//  Created by Matthew Mannucci on 4/2/23.
//

import Fluent

public enum DBMigrations {
  
  /// Returns all migrations listed in dependency order.
  ///
  /// This is useful for registering the app's migrations very easily.
  /// For example, to use in a Vapor app:
  /// ```
  /// app.migrations.add(DBMigrations.all(), to: .myDatabase)
  /// ```
  public static func all() -> [Migration] {
    // List all migrations in dependency order.
    // See https://docs.vapor.codes/fluent/migration/#register
    [
      CreateUser(),
      CreatePendingUser(),
      CreateThread(),
      CreateFriendLink(),
      CreateThreadMembership()
    ]
  }

  /// Runs migrations.
  /// 
  /// This is useful in situations in which you need to manually run a set of migrations, like when setting up a test db.
  /// 
  /// Make sure to setup a database via
  /// ```
  /// databases.use(sqlite(.memory), as: .sqlite)
  /// ```
  /// _before_ calling this function.
  /// 
  /// If no `DatabaseID` is passed to this function, the migrations will run on the default db, which
  /// is usually the first db you call `databases.use(..)` on, unless of course you explicitly set the 
  /// default db through `databases.use(..., isDefault: true)`.
  public static func runMigrations(
    _ migrations: [Migration],
    for db: DatabaseID? = nil,
    databases: Databases,
    logger: Logger,
    on eventLoop: EventLoop
  ) async throws {
    let _migrations = Migrations()
    _migrations.add(migrations, to: db)

    let migrator = Migrator(
      databases: databases,
      migrations: _migrations,
      logger: logger,
      on: eventLoop
    )

    try await migrator.setupIfNeeded().flatMap {
      migrator.prepareBatch()
    }.get()
  }
}
