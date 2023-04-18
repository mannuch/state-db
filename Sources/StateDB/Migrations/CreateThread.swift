//
//  CreateThread.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import FluentKit

struct CreateThread: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Thread.schema)
      .field("id", .string, .identifier(auto: false))
      .field("thread_content", .data)
      .field("last_content_write_at", .datetime)
      .field("friend_link_id", .uuid)
      .unique(on: "friend_link_id")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(Thread.schema).delete()
  }
}
