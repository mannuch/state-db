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
}
