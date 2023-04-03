//
//  Migrator.swift
//  
//
//  Created by Matthew Mannucci on 4/2/23.
//

import Foundation
import ConsoleKit
import Fluent
import FluentMySQLDriver
import StateDB
import NIO

@main
struct Main {
  static func main() async throws {
    let console: Console = Terminal()
    let input = CommandInput(arguments: CommandLine.arguments)
    
    var commands = Commands(enableAutocomplete: true)
    
    let threadPool = NIOThreadPool(numberOfThreads: 1)
    threadPool.start()
    
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let app = Application(threadPool: threadPool, eventLoopGroup: eventLoopGroup)
    
    let migrateCommand = MigrateCommand(app: app)
    
    commands.use(migrateCommand, as: "migrate", isDefault: true)
    
    do {
      let group = commands
        .group(help: "A command-line app to run migrations for State's database.")
      try console.run(group, input: input)
    } catch let error {
      console.error("\(error)")
      exit(1)
    }
  }
}

final class Application {
  let threadPool: NIOThreadPool
  let eventLoopGroup: EventLoopGroup
  
  let logger: Logger
  let databases: Databases
  let migrations: Migrations
  
  var migrator: Migrator {
    Migrator(
      databases: self.databases,
      migrations: self.migrations,
      logger: self.logger,
      on: self.eventLoopGroup.next()
    )
  }
  
  init(
    threadPool: NIOThreadPool,
    eventLoopGroup: EventLoopGroup
  ) {
    self.threadPool = threadPool
    self.eventLoopGroup = eventLoopGroup
    self.databases = Databases(threadPool: threadPool, on: eventLoopGroup)
    self.migrations = .init()
    self.logger = Logger(label: "app.state.migrator")
  }
  
  deinit {
    databases.shutdown()
    try? threadPool.syncShutdownGracefully()
    try? eventLoopGroup.syncShutdownGracefully()
  }
}

struct MigrateCommand: Command {
  struct Signature: CommandSignature {
    @Argument(name: "databaseURL", help: "The URL of your MySQL database.")
    var databaseURL: String
    
    @Flag(name: "revert", help: "Reverts the migration.")
    var revert: Bool
    
    @Flag(name: "autoConfirm", help: "Bypasses confirmation of migration and reversion.")
    var autoConfirm: Bool
    
    init() {}
  }
  
  let signature = Signature()
  
  var help: String {
    """
    Runs migrations (or reverts them) on the MySQL database at the specified url.
    
    Example:
    swift run Migrator migrate "mysql://username:password@127.0.0.1:3306/my-app-db"
    """
  }
  
  let app: Application
  
  init(
    app: Application
  ) {
    self.app = app
  }
  
  func run(using context: CommandContext, signature: Signature) throws {
    context.console.info("Migrate Command: \(signature.revert ? "Revert" : "Prepare")")
    
    // Setup db connection
    try app.databases.use(.mysql(url: signature.databaseURL), as: .mysql)
    
    // Register migrations
    app.migrations.add(DBMigrations.all())
    
    // Do the migrating...
    try app.migrator.setupIfNeeded().wait()
    
    if signature.revert {
      try self.revert(using: context)
    } else {
      try self.prepare(using: context)
    }
  }
  
  private func revert(using context: CommandContext) throws {
    let migrations = try self.app.migrator.previewRevertLastBatch().wait()
    guard migrations.count > 0 else {
      context.console.print("No migrations to revert.")
      return
    }
    
    context.console.print("The following migration(s) will be reverted:")
    for (migration, dbid) in migrations {
      context.console.print("- ", newLine: false)
      context.console.error(migration.name, newLine: false)
      context.console.print(" on ", newLine: false)
      context.console.print(dbid?.string ?? "default")
    }
    
    func revertBatch() throws {
      try self.app.migrator.revertLastBatch().wait()
    }
    
    if signature.autoConfirm {
      // Skipping confirmation
      try revertBatch()
    } else {
      if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
        try revertBatch()
        context.console.print("Migration successful")
      } else {
        context.console.warning("Migration cancelled")
      }
    }
  }
  
  private func prepare(using context: CommandContext) throws {
    let migrations = try self.app.migrator.previewPrepareBatch().wait()
    guard migrations.count > 0 else {
      context.console.print("No new migrations.")
      return
    }
    context.console.print("The following migration(s) will be prepared:")
    for (migration, dbid) in migrations {
      context.console.print("+ ", newLine: false)
      context.console.success(migration.name, newLine: false)
      context.console.print(" on ", newLine: false)
      context.console.print(dbid?.string ?? "default")
    }
    
    func prepareBatch() throws {
      try self.app.migrator.prepareBatch().wait()
    }
    
    if signature.autoConfirm {
      // Skipping confirmation
      try prepareBatch()
    } else {
      if context.console.confirm("Would you like to continue?".consoleText(.warning)) {
        try prepareBatch()
        context.console.print("Migration successful")
      } else {
        context.console.warning("Migration cancelled")
      }
    }
  }
  
  
}
