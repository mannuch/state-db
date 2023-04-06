//
//  FriendLink.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import FluentKit
import Foundation

public final class FriendLink: Model {
  public static let schema = "friend_links"
  
  @ID(key: .id)
  public var id: UUID?
  
  @Timestamp(key: "created_at", on: .create)
  public var createdAt: Date?
  
  @Timestamp(key: "updated_at", on: .update)
  public var updatedAt: Date?
  
  @Parent(key: "sender_id")
  public var sender: User
  
  @Parent(key: "recipient_id")
  public var recipient: User
  
  @OptionalChild(for: \.$friendLink)
  public var thread: Thread?
  
  @Enum(key: "status")
  public var status: Status
  
  public init() { }
  
  public init(
    id: UUID? = nil,
    senderId: User,
    recipientId: User,
    status: Status = .pending,
    thread: Thread? = nil
  ) throws {
    self.id = id
    self.$sender.id = try senderId.requireID()
    self.$recipient.id = try recipientId.requireID()
    self.status = status
    self.thread = thread
  }
  
  public enum Status: String, Codable {
    case accepted
    case denied
    case pending
  }
  
}

public extension FriendLink {
  
  func getSender(on db: Database) async throws -> User {
    try await self.$sender.get(on: db)
  }
  
  func getRecipient(on db: Database) async throws -> User {
    try await self.$recipient.get(on: db)
  }
}
