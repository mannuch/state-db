//
//  CreatePendingUser.swift
//  
//
//  Created by Matthew Mannucci on 3/17/23.
//

import Fluent
import FluentSQL

struct CreatePendingUser: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(PendingUser.schema)
      .id()
      .field("stytch_id", .string, .required)
      .unique(on: "stytch_id")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(PendingUser.schema).delete()
  }
}
