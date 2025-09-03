//
//  ClientCoreDataTests.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Testing
@testable import TimeTracker

struct ClientCoreDataTests {
  var context: NSManagedObjectContext!

  @Test
  func clientCreationSetsTimestamps() async throws {
    let client = Client(context: context)
    #expect(client.id != nil)
    #expect(client.createdAt != nil)
    #expect(client.modifiedAt != nil)
  }

  @Test
  func modifiedAtUpdatesOnSave() async throws {
    let client = Client(context: context)
  }
}
