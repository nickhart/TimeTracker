//
//  CoreDataServiceProtocolTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

// swiftlint:disable file_types_order

class CoreDataServiceProtocolTests: XCTestCase {
    var context: NSManagedObjectContext!
    var testService: TestService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.testService = TestService(context: self.context)

        // Clear any existing data
        try self.clearAllEntities()
    }

    override func tearDownWithError() throws {
        try self.clearAllEntities()
        self.testService = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Save Operations Tests

    func testSave_WithChanges_SavesSuccessfully() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Test Client")
        XCTAssertTrue(self.context.hasChanges)

        // When
        try self.testService.save()

        // Then
        XCTAssertFalse(self.context.hasChanges)
        let fetchedClients = self.testService.fetch(Client.self)
        XCTAssertEqual(fetchedClients.count, 1)
        XCTAssertEqual(fetchedClients.first?.name, "Test Client")
    }

    func testSave_WithoutChanges_DoesNotThrow() throws {
        // Given
        XCTAssertFalse(self.context.hasChanges)

        // When & Then
        XCTAssertNoThrow(try self.testService.save())
    }

    func testSaveIfNeeded_WithSkipSaveFalse_SavesChanges() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Test Client")
        XCTAssertTrue(self.context.hasChanges)

        // When
        try self.testService.saveIfNeeded(skipSave: false)

        // Then
        XCTAssertFalse(self.context.hasChanges)
        let fetchedClients = self.testService.fetch(Client.self)
        XCTAssertEqual(fetchedClients.count, 1)
    }

    func testSaveIfNeeded_WithSkipSaveTrue_DoesNotSave() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Test Client")
        XCTAssertTrue(self.context.hasChanges)

        // When
        try self.testService.saveIfNeeded(skipSave: true)

        // Then
        XCTAssertTrue(self.context.hasChanges)
    }

    // MARK: - Fetch Operations Tests

    func testFetch_WithoutPredicate_ReturnsAllEntities() throws {
        // Given
        let client1 = Client.createForTesting(context: self.context, name: "Client 1")
        let client2 = Client.createForTesting(context: self.context, name: "Client 2")
        try self.context.save()

        // When
        let clients = self.testService.fetch(Client.self)

        // Then
        XCTAssertEqual(clients.count, 2)
        let names = clients.map(\.name).sorted()
        XCTAssertEqual(names, ["Client 1", "Client 2"])
    }

    func testFetch_WithPredicate_ReturnsFilteredEntities() throws {
        // Given
        let client1 = Client.createForTesting(context: self.context, name: "Active Client")
        let client2 = Client.createForTesting(context: self.context, name: "Inactive Client")
        try self.context.save()

        // When
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", "active")
        let clients = self.testService.fetch(Client.self, predicate: predicate)

        // Then
        XCTAssertEqual(clients.count, 1)
        XCTAssertEqual(clients.first?.name, "Active Client")
    }

    func testFetch_WithSortDescriptors_ReturnsSortedEntities() throws {
        // Given
        let client1 = Client.createForTesting(context: self.context, name: "Zebra Client")
        let client2 = Client.createForTesting(context: self.context, name: "Alpha Client")
        try self.context.save()

        // When
        let sortDescriptor = NSSortDescriptor(keyPath: \Client.name, ascending: true)
        let clients = self.testService.fetch(Client.self, sortDescriptors: [sortDescriptor])

        // Then
        XCTAssertEqual(clients.count, 2)
        XCTAssertEqual(clients[0].name, "Alpha Client")
        XCTAssertEqual(clients[1].name, "Zebra Client")
    }

    func testFetch_WithNoResults_ReturnsEmptyArray() {
        // Given/When
        let clients = self.testService.fetch(Client.self)

        // Then
        XCTAssertEqual(clients.count, 0)
    }

    // MARK: - Count Operations Tests

    func testCount_WithoutPredicate_ReturnsCorrectCount() throws {
        // Given
        let client1 = Client.createForTesting(context: self.context, name: "Client 1")
        let client2 = Client.createForTesting(context: self.context, name: "Client 2")
        try self.context.save()

        // When
        let count = self.testService.count(Client.self)

        // Then
        XCTAssertEqual(count, 2)
    }

    func testCount_WithPredicate_ReturnsFilteredCount() throws {
        // Given
        let client1 = Client.createForTesting(context: self.context, name: "Active Client")
        let client2 = Client.createForTesting(context: self.context, name: "Inactive Client")
        try self.context.save()

        // When
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", "active")
        let count = self.testService.count(Client.self, predicate: predicate)

        // Then
        XCTAssertEqual(count, 1)
    }

    func testCount_WithNoResults_ReturnsZero() {
        // Given/When
        let count = self.testService.count(Client.self)

        // Then
        XCTAssertEqual(count, 0)
    }

    // MARK: - Exists Operations Tests

    func testExists_WithMatchingEntities_ReturnsTrue() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Test Client")
        try self.context.save()

        // When
        let exists = self.testService.exists(Client.self)

        // Then
        XCTAssertTrue(exists)
    }

    func testExists_WithPredicate_ReturnsCorrectResult() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Specific Client")
        try self.context.save()

        // When
        let existsWithPredicate = self.testService.exists(
            Client.self,
            predicate: NSPredicate(format: "name == %@", "Specific Client")
        )
        let doesNotExistWithPredicate = self.testService.exists(
            Client.self,
            predicate: NSPredicate(format: "name == %@", "Nonexistent")
        )

        // Then
        XCTAssertTrue(existsWithPredicate)
        XCTAssertFalse(doesNotExistWithPredicate)
    }

    func testExists_WithNoEntities_ReturnsFalse() {
        // Given/When
        let exists = self.testService.exists(Client.self)

        // Then
        XCTAssertFalse(exists)
    }

    // MARK: - Helper Methods

    private func clearAllEntities() throws {
        let clientRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
        let deleteClientsRequest = NSBatchDeleteRequest(fetchRequest: clientRequest)
        try context.execute(deleteClientsRequest)

        let projectRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let deleteProjectsRequest = NSBatchDeleteRequest(fetchRequest: projectRequest)
        try context.execute(deleteProjectsRequest)

        let taskRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let deleteTasksRequest = NSBatchDeleteRequest(fetchRequest: taskRequest)
        try context.execute(deleteTasksRequest)

        try self.context.save()
    }
}

// MARK: - Test Service Implementation

private class TestService: CoreDataServiceProtocol {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// swiftlint:enable file_types_order
