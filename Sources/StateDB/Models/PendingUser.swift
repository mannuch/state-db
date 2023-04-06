//
//  PendingUser.swift
//  
//
//  Created by Matthew Mannucci on 3/17/23.
//

import FluentKit
import Foundation

public final class PendingUser: Model {
  public static let schema = "pending_users"
  
  @ID(custom: .id, generatedBy: .user)
  public var id: UUID?
  
  @Field(key: "stytch_id")
  public var stytchId: String
  
  public init() { }
  
  public init(
    id: UUID,
    stytchId: String
  ) {
    self.id = id
    self.stytchId = stytchId
  }
}

public extension QueryBuilder where Model == PendingUser {
  @discardableResult
  func withStytchID(_ id: String) -> Self {
    self.filter(\.$stytchId == id)
  }
}
