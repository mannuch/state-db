//
//  CreateFriendLink.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Fluent
import FluentSQL

struct CreateFriendLink: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(FriendLink.schema)
            .id()
            .field("sender_id", .uuid, .required)
            .field("recipient_id", .uuid, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field(
                "status",
                .enum(
                    .init(
                        name: "status_type",
                        cases: ["accepted", "denied", "pending"]
                    )
                ),
                .required
            )
            .unique(on: "sender_id", "recipient_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(FriendLink.schema).delete()
    }
}
