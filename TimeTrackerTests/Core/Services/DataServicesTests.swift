//
//  DataServicesTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

class DataServicesTests: XCTestCase {
    var context: NSManagedObjectContext!
    var dataServices: DataServices!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.dataServices = DataServices(context: self.context)

        // Clear existing data
        try self.clearAllData()
    }

    override func tearDownWithError() throws {
        try self.clearAllData()
        self.dataServices = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInitialization_WithContext_InitializesAllServices() {
        // Then
        XCTAssertNotNil(self.dataServices.clientService)
        XCTAssertNotNil(self.dataServices.projectService)
        XCTAssertNotNil(self.dataServices.taskService)
        XCTAssertEqual(self.dataServices.context, self.context)
    }

    // MARK: - Coordinated Operations Tests

    func testCreateProjectWithTask_CreatesProjectAndTaskInSingleTransaction() throws {
        // Given
        let client = try dataServices.clientService.createClient(name: "Test Client")

        // When
        let (project, task) = try dataServices.createProjectWithTask(
            client: client,
            projectName: "Test Project",
            taskName: "Test Task"
        )

        // Then
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.client, client)
        XCTAssertEqual(task.name, "Test Task")
        XCTAssertEqual(task.client, client)
        XCTAssertEqual(task.project, project)
        XCTAssertFalse(self.context.hasChanges) // Should be saved in single transaction

        // Verify both entities are persisted
        let fetchedProjects = self.dataServices.projectService.getProjects(for: client)
        let fetchedTasks = self.dataServices.taskService.getTasks(for: client)
        XCTAssertEqual(fetchedProjects.count, 1)
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.project, fetchedProjects.first)
    }

    func testCreateProjectWithTask_WithInvalidProjectName_ThrowsValidationError() throws {
        // Given
        let client = try dataServices.clientService.createClient(name: "Test Client")

        // When/Then
        XCTAssertThrowsError(try self.dataServices.createProjectWithTask(
            client: client,
            projectName: "",
            taskName: "Valid Task"
        )) { error in
            XCTAssertTrue(error is ProjectService.ValidationError)
        }

        // Verify no entities were created due to transaction rollback
        let fetchedProjects = self.dataServices.projectService.getProjects(for: client)
        let fetchedTasks = self.dataServices.taskService.getTasks(for: client)
        XCTAssertEqual(fetchedProjects.count, 0)
        XCTAssertEqual(fetchedTasks.count, 0)
    }

    func testCreateProjectWithTask_WithInvalidTaskName_ThrowsValidationError() throws {
        // Given
        let client = try dataServices.clientService.createClient(name: "Test Client")

        // When/Then
        XCTAssertThrowsError(try self.dataServices.createProjectWithTask(
            client: client,
            projectName: "Valid Project",
            taskName: ""
        )) { error in
            XCTAssertTrue(error is TaskService.ValidationError)
        }

        // Verify no entities were created due to transaction rollback
        let fetchedProjects = self.dataServices.projectService.getProjects(for: client)
        let fetchedTasks = self.dataServices.taskService.getTasks(for: client)
        XCTAssertEqual(fetchedProjects.count, 0)
        XCTAssertEqual(fetchedTasks.count, 0)
    }

    // MARK: - Save Operations Tests

    func testSave_WithChanges_SavesSuccessfully() throws {
        // Given
        let client = Client.createForTesting(context: self.context, name: "Test Client")
        XCTAssertTrue(self.context.hasChanges)

        // When
        try self.dataServices.save()

        // Then
        XCTAssertFalse(self.context.hasChanges)
        let fetchedClients = self.dataServices.clientService.getAllClients()
        XCTAssertEqual(fetchedClients.count, 1)
    }

    func testSave_WithoutChanges_DoesNotThrow() throws {
        // Given
        XCTAssertFalse(self.context.hasChanges)

        // When/Then
        XCTAssertNoThrow(try self.dataServices.save())
    }

    // MARK: - Service Access Tests

    func testServiceAccess_AllServicesShareSameContext() {
        // Then
        XCTAssertEqual(self.dataServices.clientService.context, self.context)
        XCTAssertEqual(self.dataServices.projectService.context, self.context)
        XCTAssertEqual(self.dataServices.taskService.context, self.context)
        XCTAssertEqual(self.dataServices.context, self.context)
    }

    func testServiceIntegration_WorkflowTest() throws {
        // This tests a realistic workflow using multiple services

        // Step 1: Create a client
        let client = try dataServices.clientService.createClient(name: "Acme Corp")

        // Step 2: Create a project for the client
        let project = try dataServices.projectService.createProject(for: client, name: "Website Redesign")

        // Step 3: Create a task for the project
        let task = try dataServices.taskService.createTask(name: "Design Homepage", client: client, project: project)

        // Step 4: Start and stop the timer
        try self.dataServices.taskService.startTimer(for: task)
        try self.dataServices.taskService.stopTimer(for: task)

        // Verify the complete workflow worked
        XCTAssertEqual(self.dataServices.clientService.getAllClients().count, 1)
        XCTAssertEqual(self.dataServices.projectService.getProjects(for: client).count, 1)
        XCTAssertEqual(self.dataServices.taskService.getTasks(for: client).count, 1)
        XCTAssertEqual(self.dataServices.taskService.getCompletedTasks(for: client).count, 1)

        let completedTask = self.dataServices.taskService.getCompletedTasks(for: client).first!
        XCTAssertNotNil(completedTask.startTime)
        XCTAssertNotNil(completedTask.endTime)
        XCTAssertEqual(completedTask.client, client)
        XCTAssertEqual(completedTask.project, project)
    }

    // MARK: - Performance Tests

    func testCreateProjectWithTask_Performance() {
        // Given
        guard let client = try? dataServices.clientService.createClient(name: "Performance Test Client") else {
            XCTFail("Could not create test client")
            return
        }

        // Measure the performance of coordinated operation
        measure {
            for i in 1...100 {
                _ = try? self.dataServices.createProjectWithTask(
                    client: client,
                    projectName: "Project \(i)",
                    taskName: "Task \(i)"
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func clearAllData() throws {
        let taskRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let deleteTasksRequest = NSBatchDeleteRequest(fetchRequest: taskRequest)
        try context.execute(deleteTasksRequest)

        let projectRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let deleteProjectsRequest = NSBatchDeleteRequest(fetchRequest: projectRequest)
        try context.execute(deleteProjectsRequest)

        let clientRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
        let deleteClientsRequest = NSBatchDeleteRequest(fetchRequest: clientRequest)
        try context.execute(deleteClientsRequest)

        try self.context.save()
    }
}
