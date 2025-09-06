//
//  ClientServiceTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

class ClientServiceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var clientService: ClientService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.clientService = ClientService(context: self.context)

        // Clear any existing data
        try self.clearAllClients()
    }

    override func tearDownWithError() throws {
        try self.clearAllClients()
        self.clientService = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Create Client Tests

    func testCreateClient_WithValidName_CreatesAndSavesClient() throws {
        // When
        let client = try clientService.createClient(name: "Test Client")

        // Then
        XCTAssertNotNil(client)
        XCTAssertEqual(client.name, "Test Client")
        XCTAssertNotNil(client.createdAt)
        XCTAssertNotNil(client.modifiedAt)
        XCTAssertFalse(self.context.hasChanges) // Should be saved automatically

        // Verify it's actually saved
        let fetchedClients = self.clientService.fetch(Client.self)
        XCTAssertEqual(fetchedClients.count, 1)
        XCTAssertEqual(fetchedClients.first?.name, "Test Client")
    }

    func testCreateClient_WithSkipSave_DoesNotSaveToContext() throws {
        // When
        let client = try clientService.createClient(name: "Test Client", skipSave: true)

        // Then
        XCTAssertNotNil(client)
        XCTAssertEqual(client.name, "Test Client")
        XCTAssertTrue(self.context.hasChanges) // Should not be saved

        // Verify it's not persisted yet
        self.context.rollback()
        let fetchedClients = self.clientService.fetch(Client.self)
        XCTAssertEqual(fetchedClients.count, 0)
    }

    func testCreateClient_WithEmptyName_ThrowsValidationError() {
        // When/Then
        XCTAssertThrowsError(try self.clientService.createClient(name: "")) { error in
            XCTAssertTrue(error is ClientService.ValidationError)
            if case ClientService.ValidationError.emptyName = error {
                // Expected error
            } else {
                XCTFail("Expected ValidationError.emptyName")
            }
        }
    }

    func testCreateClient_WithWhitespaceOnlyName_ThrowsValidationError() {
        // When/Then
        XCTAssertThrowsError(try self.clientService.createClient(name: "   ")) { error in
            XCTAssertTrue(error is ClientService.ValidationError)
        }
    }

    // MARK: - Get All Clients Tests

    func testGetAllClients_WithNoClients_ReturnsEmptyArray() {
        // When
        let clients = self.clientService.getAllClients()

        // Then
        XCTAssertEqual(clients.count, 0)
    }

    func testGetAllClients_WithMultipleClients_ReturnsAllClientsSortedByName() throws {
        // Given
        try self.clientService.createClient(name: "Zebra Corp")
        try self.clientService.createClient(name: "Alpha Inc")
        try self.clientService.createClient(name: "Beta LLC")

        // When
        let clients = self.clientService.getAllClients()

        // Then
        XCTAssertEqual(clients.count, 3)
        XCTAssertEqual(clients[0].name, "Alpha Inc")
        XCTAssertEqual(clients[1].name, "Beta LLC")
        XCTAssertEqual(clients[2].name, "Zebra Corp")
    }

    // MARK: - Get Active Clients Tests

    func testGetActiveClients_WithAllActiveClients_ReturnsAllClients() throws {
        // Given
        let client1 = try clientService.createClient(name: "Client 1")
        let client2 = try clientService.createClient(name: "Client 2")

        // When
        let activeClients = self.clientService.getActiveClients()

        // Then
        XCTAssertEqual(activeClients.count, 2)
    }

    func testGetActiveClients_WithInactiveClients_ExcludesInactiveClients() throws {
        // Given
        let activeClient = try clientService.createClient(name: "Active Client")
        let inactiveClient = try clientService.createClient(name: "Inactive Client")
        inactiveClient.isActive = false
        try self.context.save()

        // When
        let activeClients = self.clientService.getActiveClients()

        // Then
        XCTAssertEqual(activeClients.count, 1)
        XCTAssertEqual(activeClients.first?.name, "Active Client")
    }

    // MARK: - Delete Client Tests

    func testDeleteClient_WithExistingClient_DeletesSuccessfully() throws {
        // Given
        let client = try clientService.createClient(name: "Client to Delete")
        XCTAssertEqual(self.clientService.getAllClients().count, 1)

        // When
        try self.clientService.deleteClient(client)

        // Then
        XCTAssertEqual(self.clientService.getAllClients().count, 0)
        XCTAssertFalse(self.context.hasChanges) // Should be saved
    }

    func testDeleteClient_WithSkipSave_DoesNotSaveToContext() throws {
        // Given
        let client = try clientService.createClient(name: "Client to Delete")

        // When
        try self.clientService.deleteClient(client, skipSave: true)

        // Then
        XCTAssertTrue(self.context.hasChanges) // Should not be saved yet

        // Verify deletion will occur when saved
        try self.context.save()
        XCTAssertEqual(self.clientService.getAllClients().count, 0)
    }

    // MARK: - Update Client Tests

    func testUpdateClient_WithNewName_UpdatesSuccessfully() throws {
        // Given
        let client = try clientService.createClient(name: "Original Name")
        let originalModifiedAt = client.modifiedAt

        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        try self.clientService.updateClient(client, name: "Updated Name")

        // Then
        XCTAssertEqual(client.name, "Updated Name")
        XCTAssertNotEqual(client.modifiedAt, originalModifiedAt)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testUpdateClient_WithSameName_StillUpdatesTimestamp() throws {
        // Given
        let client = try clientService.createClient(name: "Same Name")
        let originalModifiedAt = client.modifiedAt

        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        try self.clientService.updateClient(client, name: "Same Name")

        // Then
        XCTAssertEqual(client.name, "Same Name")
        XCTAssertNotEqual(client.modifiedAt, originalModifiedAt)
    }

    func testUpdateClient_WithEmptyName_ThrowsValidationError() throws {
        // Given
        let client = try clientService.createClient(name: "Valid Name")

        // When/Then
        XCTAssertThrowsError(try self.clientService.updateClient(client, name: "")) { error in
            XCTAssertTrue(error is ClientService.ValidationError)
        }
    }

    // MARK: - Helper Methods

    private func clearAllClients() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try self.context.save()
    }
}
