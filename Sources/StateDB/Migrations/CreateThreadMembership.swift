//
//  CreateThreadMembership.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Fluent
import FluentSQL

struct CreateThreadMembership: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ThreadMembership.schema)
            .field("user_id", .uuid, .required)
            .field("thread_id", .string, .required)
            .compositeIdentifier(over: "user_id", "thread_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(ThreadMembership.schema).delete()
    }
}


