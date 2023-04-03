//
//  User.swift
//  
//
//  Created by Matthew Mannucci on 9/3/22.
//

import Fluent
import Vapor
import OrderedCollections

public final class User: Model, Content {
  public static let schema = "users"
  
  @ID(custom: .id, generatedBy: .user)
  public var id: UUID?
  
  @Field(key: "name")
  public var name: String
  
  @Field(key: "handle")
  public var handle: String
  
  @Field(key: "profile_image_url")
  public var profileImageUrl: String
  
  @Field(key: "location")
  public var location: Location

  @Field(key: "device_ids")
  public var deviceIds: [String]
  
  @Children(for: \.$id.$user)
  public var threadMemberships: [ThreadMembership]
  
  @Siblings(through: ThreadMembership.self, from: \.$id.$user, to: \.$id.$thread)
  public var threads: [Thread]
  
  // User on 'sender'-side of friend request pivot table
  @Children(for: \.$sender)
  public var sentFriendLinks: [FriendLink]
  
  /// All the users that currently have friend links addressed **from** this user.
  @Siblings(through: FriendLink.self, from: \.$sender, to: \.$recipient)
  public var sentFriendLinkUsers: [User]
  
  // User on 'recipient'-side of friend request pivot table
  @Children(for: \.$recipient)
  public var recievedFriendLinks: [FriendLink]
  
  /// All the users that currently have friend links addressed **to** this user.
  @Siblings(through: FriendLink.self, from: \.$recipient, to: \.$sender)
  public var recievedFriendLinkUsers: [User]
  
  @Group(key: "stytch")
  public var stytch: Stytch
  
  public init() { }
  
  public init(
    id: UUID,
    name: String,
    handle: String,
    profileImageUrl: String,
    location: Location,
    stytch: Stytch,
    deviceIds: [String] = []
  ) {
    self.id = id
    self.name = name
    self.handle = handle
    self.profileImageUrl = profileImageUrl
    self.location = location
    self.stytch = stytch
    self.deviceIds = deviceIds
  }
  
  public struct Location: Codable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }
  }
  
  public final class Stytch: Fields {
    
    @Field(key: "user_id")
    public var userId: String
    
    public init() { }
    
    public init(
      userId: String
    ) {
      self.userId = userId
    }
  }
}

extension User: Equatable, Hashable {
  
  public static func ==(lhs: User, rhs: User) -> Bool {
    do {
      return try lhs.requireID() == rhs.requireID()
    } catch {
      return lhs.handle == rhs.handle
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    do {
      return try hasher.combine(self.requireID())
    } catch {
      return hasher.combine(self.handle)
    }
  }
}

public extension User {
  
  /// Returns all the recieved friend links whose status is `.pending`.
  ///
  /// Will fail if `self.recievedFriendLinks` is not yet loaded from the database.
  var recievedPendingFriendLinks: [FriendLink] {
    self.recievedFriendLinks.filter { $0.status == .pending }
  }
  
  /// Lazily loads friends links if they haven't been loaded yet.
  func loadFriendLinks(on db: Database) async throws {
    self.$sentFriendLinks.value == nil ? try await self.$sentFriendLinks.load(on: db) : ()
    self.$recievedFriendLinks.value == nil ?  try await self.$recievedFriendLinks.load(on: db) : ()
    return
    
  }
  
  /// Lazily loads friend link users if they haven't been loaded yet.
  func loadFriendLinkUsers(on db: Database) async throws {
    self.$sentFriendLinkUsers.value == nil ? try await self.$sentFriendLinkUsers.load(on: db) : ()
    self.$recievedFriendLinkUsers.value == nil ?  try await self.$recievedFriendLinkUsers.load(on: db) : ()
    return
  }
  
  /// Lazily loads threads if they haven't been loaded yet.
  func loadThreads(on db: Database) async throws {
    return self.$threads.value == nil ? try await self.$threads.load(on: db) : ()
  }
}
