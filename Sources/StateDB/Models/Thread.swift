//
//  Thread.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Fluent
import Vapor
import Foundation
import ULID

public final class Thread: Model, Content {
  public static let schema = "threads"
  
  @ID(custom: .id, generatedBy: .user)
  public var id: String?

  @OptionalField(key: "thread_content")
  public var threadContent: Data?
  
  @Children(for: \.$id.$thread)
  public var threadMemberships: [ThreadMembership]
  
  @Siblings(through: ThreadMembership.self, from: \.$id.$thread, to: \.$id.$user)
  public var users: [User]
  
  @OptionalParent(key: "friend_link_id")
  public var friendLink: FriendLink?
  
  public init() { }
  
  public init(
    id: ULID,
    friendLinkId: FriendLink.IDValue? = nil,
    threadContent: Data? = nil
  ) {
    self.id = id.ulidString
    self.threadContent = threadContent
    self.$friendLink.id = friendLinkId
  }
}

public extension Thread {
  
  /// Like `self.requireID()`, except returns as `ULID`.
  func requireULID() throws -> ULID {
    ULID(ulidString: try self.requireID())!
  }
}
