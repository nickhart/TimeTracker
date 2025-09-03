//
//  TaskCoreDataTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/3/25.
//

import Testing

import CoreData
@testable import TimeTracker

@Suite(.serialized)
final class TaskCoreDataTests {
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        // Create in-memory Core Data stack for testing
        self.container = NSPersistentContainer(name: "TimeTracker")
        self.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        var loadError: Error?
        self.container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            fatalError("Failed to load Core Data stack: \(error)")
        }

        self.context = self.container.viewContext
        self.context.automaticallyMergesChangesFromParent = true
    }

    @Test
    func taskCreationSetsTimestamps() async throws {
        let task = Task(context: context)
        #expect(task.id != nil)
        #expect(task.createdAt != nil)
        #expect(task.modifiedAt != nil)
    }

    @Test
    func modifiedAtUpdatesOnSave() async throws {
        let task = Task(context: context)

        // Set initial timestamps manually (bypassing awakeFromInsert behavior)
        let initialDate = Date(timeIntervalSince1970: 1000)
        task.createdAt = initialDate
        task.modifiedAt = initialDate
        task.name = "Initial Name"
        try self.context.save()

        // Verify initial state
        #expect(task.modifiedAt == initialDate)

        // Make a change and save
        task.name = "Updated Name"
        try self.context.save()

        // modifiedAt should now be newer than our initial date
        #expect(task.modifiedAt! > initialDate)
        #expect(task.createdAt == initialDate) // createdAt should not change
    }

    @Test
    func modifiedAtOnlyUpdatesOnActualChanges() async throws {
        let task = Task(context: context)

        // Set initial state
        let initialDate = Date(timeIntervalSince1970: 1000)
        task.createdAt = initialDate
        task.modifiedAt = initialDate
        task.name = "Test Task"
        try self.context.save()

        // Save again without changes
        try self.context.save()

        // modifiedAt should not have changed
        #expect(task.modifiedAt == initialDate)
    }
}
