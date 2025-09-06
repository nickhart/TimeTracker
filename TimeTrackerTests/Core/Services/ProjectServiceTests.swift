//
//  ProjectServiceTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

class ProjectServiceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var projectService: ProjectService!
    var clientService: ClientService!
    var testClient: Client!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.projectService = ProjectService(context: self.context)
        self.clientService = ClientService(context: self.context)

        // Clear existing data and create test client
        try self.clearAllData()
        self.testClient = try self.clientService.createClient(name: "Test Client")
    }

    override func tearDownWithError() throws {
        try self.clearAllData()
        self.projectService = nil
        self.clientService = nil
        self.testClient = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Create Project Tests

    func testCreateProject_WithValidData_CreatesAndSavesProject() throws {
        // When
        let project = try projectService.createProject(for: self.testClient, name: "Test Project")

        // Then
        XCTAssertNotNil(project)
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.client, self.testClient)
        XCTAssertNotNil(project.createdAt)
        XCTAssertNotNil(project.modifiedAt)
        XCTAssertFalse(self.context.hasChanges)

        // Verify relationship
        XCTAssertTrue(self.testClient.projects?.contains(project) == true)
    }

    func testCreateProject_WithSkipSave_DoesNotSaveToContext() throws {
        // When
        let project = try projectService.createProject(for: self.testClient, name: "Test Project", skipSave: true)

        // Then
        XCTAssertNotNil(project)
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.client, self.testClient)
        XCTAssertTrue(self.context.hasChanges)

        // Verify it's not persisted yet
        self.context.rollback()
        let fetchedProjects = self.projectService.fetch(Project.self)
        XCTAssertEqual(fetchedProjects.count, 0)
    }

    func testCreateProject_WithEmptyName_ThrowsValidationError() {
        // When/Then
        XCTAssertThrowsError(try self.projectService.createProject(for: self.testClient, name: "")) { error in
            XCTAssertTrue(error is ProjectService.ValidationError)
            if case ProjectService.ValidationError.emptyName = error {
                // Expected error
            } else {
                XCTFail("Expected ValidationError.emptyName")
            }
        }
    }

    func testCreateProject_WithWhitespaceOnlyName_ThrowsValidationError() {
        // When/Then
        XCTAssertThrowsError(try self.projectService.createProject(for: self.testClient, name: "   ")) { error in
            XCTAssertTrue(error is ProjectService.ValidationError)
        }
    }

    // MARK: - Get Projects Tests

    func testGetProjects_ForClient_ReturnsClientProjectsSortedByName() throws {
        // Given
        let otherClient = try clientService.createClient(name: "Other Client")
        try self.projectService.createProject(for: self.testClient, name: "Zebra Project")
        try self.projectService.createProject(for: self.testClient, name: "Alpha Project")
        try self.projectService.createProject(for: otherClient, name: "Other Project")

        // When
        let projects = self.projectService.getProjects(for: self.testClient)

        // Then
        XCTAssertEqual(projects.count, 2)
        XCTAssertEqual(projects[0].name, "Alpha Project")
        XCTAssertEqual(projects[1].name, "Zebra Project")

        // Verify all belong to correct client
        for project in projects {
            XCTAssertEqual(project.client, self.testClient)
        }
    }

    func testGetProjects_ForClientWithNoProjects_ReturnsEmptyArray() {
        // When
        let projects = self.projectService.getProjects(for: self.testClient)

        // Then
        XCTAssertEqual(projects.count, 0)
    }

    func testGetActiveProjects_ForClient_ExcludesInactiveProjects() throws {
        // Given
        let activeProject = try projectService.createProject(for: self.testClient, name: "Active Project")
        let inactiveProject = try projectService.createProject(for: self.testClient, name: "Inactive Project")
        inactiveProject.isActive = false
        try self.context.save()

        // When
        let activeProjects = self.projectService.getActiveProjects(for: self.testClient)

        // Then
        XCTAssertEqual(activeProjects.count, 1)
        XCTAssertEqual(activeProjects.first?.name, "Active Project")
    }

    func testGetAllProjects_ReturnsAllProjectsSortedByName() throws {
        // Given
        let client1 = self.testClient!
        let client2 = try clientService.createClient(name: "Client 2")

        try self.projectService.createProject(for: client2, name: "Beta Project")
        try self.projectService.createProject(for: client1, name: "Alpha Project")
        try self.projectService.createProject(for: client1, name: "Gamma Project")

        // When
        let allProjects = self.projectService.getAllProjects()

        // Then
        XCTAssertEqual(allProjects.count, 3)
        XCTAssertEqual(allProjects[0].name, "Alpha Project")
        XCTAssertEqual(allProjects[1].name, "Beta Project")
        XCTAssertEqual(allProjects[2].name, "Gamma Project")
    }

    // MARK: - Update Project Tests

    func testUpdateProject_WithNewName_UpdatesSuccessfully() throws {
        // Given
        let project = try projectService.createProject(for: self.testClient, name: "Original Name")
        let originalModifiedAt = project.modifiedAt

        // Wait to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        try self.projectService.updateProject(project, name: "Updated Name")

        // Then
        XCTAssertEqual(project.name, "Updated Name")
        XCTAssertNotEqual(project.modifiedAt, originalModifiedAt)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testUpdateProject_WithEmptyName_ThrowsValidationError() throws {
        // Given
        let project = try projectService.createProject(for: self.testClient, name: "Valid Name")

        // When/Then
        XCTAssertThrowsError(try self.projectService.updateProject(project, name: "")) { error in
            XCTAssertTrue(error is ProjectService.ValidationError)
        }
    }

    func testUpdateProject_WithSkipSave_DoesNotSaveToContext() throws {
        // Given
        let project = try projectService.createProject(for: self.testClient, name: "Original Name")

        // When
        try self.projectService.updateProject(project, name: "Updated Name", skipSave: true)

        // Then
        XCTAssertEqual(project.name, "Updated Name")
        XCTAssertTrue(self.context.hasChanges)
    }

    // MARK: - Delete Project Tests

    func testDeleteProject_WithExistingProject_DeletesSuccessfully() throws {
        // Given
        let project = try projectService.createProject(for: self.testClient, name: "Project to Delete")
        XCTAssertEqual(self.projectService.getProjects(for: self.testClient).count, 1)

        // When
        try self.projectService.deleteProject(project)

        // Then
        XCTAssertEqual(self.projectService.getProjects(for: self.testClient).count, 0)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testDeleteProject_WithSkipSave_DoesNotSaveToContext() throws {
        // Given
        let project = try projectService.createProject(for: self.testClient, name: "Project to Delete")

        // When
        try self.projectService.deleteProject(project, skipSave: true)

        // Then
        XCTAssertTrue(self.context.hasChanges)

        // Verify deletion occurs when saved
        try self.context.save()
        XCTAssertEqual(self.projectService.getProjects(for: self.testClient).count, 0)
    }

    // MARK: - Helper Methods

    private func clearAllData() throws {
        let projectRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let deleteProjectsRequest = NSBatchDeleteRequest(fetchRequest: projectRequest)
        try context.execute(deleteProjectsRequest)

        let clientRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
        let deleteClientsRequest = NSBatchDeleteRequest(fetchRequest: clientRequest)
        try context.execute(deleteClientsRequest)

        try self.context.save()
    }
}
