//
//  ThreadMembership.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Foundation
import FluentKit

/// See https://github.com/vapor/fluent-kit/blob/main/Tests/FluentKitTests/CompositeIDTests.swift for how to use composite (multi-column) primary keys in context of pivot tables.

public final class ThreadMembership: Model {
  public static let schema = "thread_memberships"
  
  @CompositeID
  public var id: IDValue?
  
  public init() { }
  
  public init(userId: User.IDValue, threadId: Thread.IDValue) {
    self.id = .init(userId: userId, threadId: threadId)
  }
  
  public init(id: IDValue) {
    self.id = id
  }
  
  public convenience init(user: User, thread: Thread) throws {
    try self.init(id: IDValue(user: user, thread: thread))
  }
  
  public final class IDValue: Fields, Hashable {
    
    @Parent(key: "user_id")
    public var user: User
    
    @Parent(key: "thread_id")
    public var thread: Thread
    
    public init() { }
    
    public init(userId: User.IDValue, threadId: Thread.IDValue) {
      self.$user.id = userId
      self.$thread.id = threadId
    }
    
    public convenience init(user: User, thread: Thread) throws {
      try self.init(userId: user.requireID(), threadId: thread.requireID())
    }
    
    public static func ==(lhs: IDValue, rhs: IDValue) -> Bool {
      lhs.$user.id == rhs.$user.id && lhs.$thread.id == rhs.$thread.id
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(self.$user.id)
      hasher.combine(self.$thread.id)
    }
    
  }
}
