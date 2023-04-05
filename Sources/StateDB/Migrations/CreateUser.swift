//
//  CreateUser.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Fluent
import FluentSQL

struct CreateUser: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(User.schema)
      .id()
      .field("name", .string, .required)
      .field("handle", .string, .required)
      .field("profile_image_url", .string, .required)
      .field("location", .dictionary, .required)
      .field("device_tokens", .array(of: .string), .required)
      .field("stytch_user_id", .string, .required)
      .unique(on: "stytch_user_id")
      .unique(on: "handle")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(User.schema).delete()
  }
}
