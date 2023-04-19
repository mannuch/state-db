//
//  Thread.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import FluentKit
import Foundation
import ULID

let SECS_PER_DAY: TimeInterval = 86400

public final class Thread: Model {
  public static let schema = "threads"
  
  @ID(custom: .id, generatedBy: .user)
  public var id: String?

  @OptionalField(key: "thread_content")
  public var threadContent: Data?
  
  @OptionalField(key: "last_content_write_at")
  public var lastContentWriteAt: Date?
  
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
    threadContent: Data? = nil,
    lastContentWriteAt: Date? = nil
  ) {
    self.id = id.ulidString
    self.threadContent = threadContent
    self.lastContentWriteAt = lastContentWriteAt
    self.$friendLink.id = friendLinkId
  }
}

public extension Thread {
  
  /// Like `self.requireID()`, except returns as `ULID`.
  func requireULID() throws -> ULID {
    ULID(ulidString: try self.requireID())!
  }
}

public extension Thread {
  var checkedThreadContent: Data? {
    self.lastContentWriteAt.flatMap { lastContentWriteAt in
      if lastContentWriteAt.is24HoursAgo { return nil }
      return self.threadContent
    }
  }
}

extension Date {
  var is24HoursAgo: Bool {
    self < Date(timeIntervalSinceNow: -SECS_PER_DAY)
  }
}
