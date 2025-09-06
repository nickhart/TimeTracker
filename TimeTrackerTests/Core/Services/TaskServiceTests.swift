//
//  TaskServiceTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

class TaskServiceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var taskService: TaskService!
    var clientService: ClientService!
    var projectService: ProjectService!
    var testClient: Client!
    var testProject: Project!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.taskService = TaskService(context: self.context)
        self.clientService = ClientService(context: self.context)
        self.projectService = ProjectService(context: self.context)

        // Clear existing data and create test entities
        try self.clearAllData()
        self.testClient = try self.clientService.createClient(name: "Test Client")
        self.testProject = try self.projectService.createProject(for: self.testClient, name: "Test Project")
    }

    override func tearDownWithError() throws {
        try self.clearAllData()
        self.taskService = nil
        self.clientService = nil
        self.projectService = nil
        self.testClient = nil
        self.testProject = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Create Task Tests

    func testCreateTask_WithValidData_CreatesAndSavesTask() throws {
        // When
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: self.testProject)

        // Then
        XCTAssertNotNil(task)
        XCTAssertEqual(task.name, "Test Task")
        XCTAssertEqual(task.client, self.testClient)
        XCTAssertEqual(task.project, self.testProject)
        XCTAssertNotNil(task.createdAt)
        XCTAssertNotNil(task.modifiedAt)
        XCTAssertNil(task.startTime)
        XCTAssertNil(task.endTime)
        XCTAssertFalse(self.context.hasChanges)

        // Verify relationships
        XCTAssertTrue(self.testClient.tasks?.contains(task) == true)
        XCTAssertTrue(self.testProject.tasks?.contains(task) == true)
    }

    func testCreateTask_WithClientOnly_CreatesTaskWithoutProject() throws {
        // When
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: nil)

        // Then
        XCTAssertEqual(task.client, self.testClient)
        XCTAssertNil(task.project)
        XCTAssertTrue(self.testClient.tasks?.contains(task) == true)
    }

    func testCreateTask_WithSkipSave_DoesNotSaveToContext() throws {
        // When
        let task = try taskService.createTask(
            name: "Test Task",
            client: self.testClient,
            project: self.testProject,
            skipSave: true
        )

        // Then
        XCTAssertNotNil(task)
        XCTAssertTrue(self.context.hasChanges)

        // Verify it's not persisted yet
        self.context.rollback()
        let fetchedTasks = self.taskService.fetch(Task.self)
        XCTAssertEqual(fetchedTasks.count, 0)
    }

    func testCreateTask_WithEmptyName_ThrowsValidationError() {
        // When/Then
        XCTAssertThrowsError(try self.taskService.createTask(
            name: "",
            client: self.testClient,
            project: self.testProject
        )) { error in
            XCTAssertTrue(error is TaskService.ValidationError)
            if case TaskService.ValidationError.emptyName = error {
                // Expected error
            } else {
                XCTFail("Expected ValidationError.emptyName")
            }
        }
    }

    // MARK: - Start/Stop Timer Tests

    func testStartTimer_OnTask_SetsStartTime() throws {
        // Given
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: self.testProject)
        XCTAssertNil(task.startTime)

        // When
        try self.taskService.startTimer(for: task)

        // Then
        XCTAssertNotNil(task.startTime)
        XCTAssertNil(task.endTime)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testStopTimer_OnRunningTask_SetsEndTime() throws {
        // Given
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: self.testProject)
        try self.taskService.startTimer(for: task)
        XCTAssertNotNil(task.startTime)
        XCTAssertNil(task.endTime)

        // When
        try self.taskService.stopTimer(for: task)

        // Then
        XCTAssertNotNil(task.startTime)
        XCTAssertNotNil(task.endTime)
        XCTAssertGreaterThanOrEqual(task.endTime!, task.startTime!)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testStopTimer_OnTaskWithoutStartTime_ThrowsValidationError() throws {
        // Given
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: self.testProject)
        XCTAssertNil(task.startTime)

        // When/Then
        XCTAssertThrowsError(try self.taskService.stopTimer(for: task)) { error in
            XCTAssertTrue(error is TaskService.ValidationError)
            if case TaskService.ValidationError.taskNotRunning = error {
                // Expected error
            } else {
                XCTFail("Expected ValidationError.taskNotRunning")
            }
        }
    }

    func testStartTimer_OnAlreadyRunningTask_ThrowsValidationError() throws {
        // Given
        let task = try taskService.createTask(name: "Test Task", client: self.testClient, project: self.testProject)
        try self.taskService.startTimer(for: task)

        // When/Then
        XCTAssertThrowsError(try self.taskService.startTimer(for: task)) { error in
            XCTAssertTrue(error is TaskService.ValidationError)
            if case TaskService.ValidationError.taskAlreadyRunning = error {
                // Expected error
            } else {
                XCTFail("Expected ValidationError.taskAlreadyRunning")
            }
        }
    }

    // MARK: - Get Tasks Tests

    func testGetTasks_ForClient_ReturnsClientTasksSortedByCreatedDate() throws {
        // Given
        let otherClient = try clientService.createClient(name: "Other Client")
        let task1 = try taskService.createTask(name: "Task 1", client: self.testClient, project: self.testProject)
        Thread.sleep(forTimeInterval: 0.01) // Ensure different timestamps
        let task2 = try taskService.createTask(name: "Task 2", client: self.testClient, project: self.testProject)
        try self.taskService.createTask(name: "Other Task", client: otherClient, project: nil)

        // When
        let tasks = self.taskService.getTasks(for: self.testClient)

        // Then
        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks[0], task2) // Most recent first
        XCTAssertEqual(tasks[1], task1)
    }

    func testGetTasks_ForProject_ReturnsProjectTasksSortedByCreatedDate() throws {
        // Given
        let otherProject = try projectService.createProject(for: self.testClient, name: "Other Project")
        let task1 = try taskService.createTask(name: "Task 1", client: self.testClient, project: self.testProject)
        let task2 = try taskService.createTask(name: "Task 2", client: self.testClient, project: self.testProject)
        try self.taskService.createTask(name: "Other Task", client: self.testClient, project: otherProject)

        // When
        let tasks = self.taskService.getTasks(for: self.testProject)

        // Then
        XCTAssertEqual(tasks.count, 2)
        for task in tasks {
            XCTAssertEqual(task.project, self.testProject)
        }
    }

    func testGetCompletedTasks_ExcludesRunningTasks() throws {
        // Given
        let completedTask = try taskService.createTask(
            name: "Completed Task",
            client: self.testClient,
            project: self.testProject
        )
        try self.taskService.startTimer(for: completedTask)
        try self.taskService.stopTimer(for: completedTask)

        let runningTask = try taskService.createTask(
            name: "Running Task",
            client: self.testClient,
            project: self.testProject
        )
        try self.taskService.startTimer(for: runningTask)

        let unStartedTask = try taskService.createTask(
            name: "Unstarted Task",
            client: self.testClient,
            project: self.testProject
        )

        // When
        let completedTasks = self.taskService.getCompletedTasks(for: self.testClient)

        // Then
        XCTAssertEqual(completedTasks.count, 1)
        XCTAssertEqual(completedTasks.first, completedTask)
    }

    func testGetRunningTasks_OnlyReturnsTasksWithStartTimeAndNoEndTime() throws {
        // Given
        let completedTask = try taskService.createTask(
            name: "Completed Task",
            client: self.testClient,
            project: self.testProject
        )
        try self.taskService.startTimer(for: completedTask)
        try self.taskService.stopTimer(for: completedTask)

        let runningTask = try taskService.createTask(
            name: "Running Task",
            client: self.testClient,
            project: self.testProject
        )
        try self.taskService.startTimer(for: runningTask)

        let unStartedTask = try taskService.createTask(
            name: "Unstarted Task",
            client: self.testClient,
            project: self.testProject
        )

        // When
        let runningTasks = self.taskService.getRunningTasks()

        // Then
        XCTAssertEqual(runningTasks.count, 1)
        XCTAssertEqual(runningTasks.first, runningTask)
    }

    // MARK: - Update Task Tests

    func testUpdateTask_WithNewName_UpdatesSuccessfully() throws {
        // Given
        let task = try taskService.createTask(name: "Original Name", client: self.testClient, project: self.testProject)
        let originalModifiedAt = task.modifiedAt

        // Wait to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        // When
        try self.taskService.updateTask(task, name: "Updated Name")

        // Then
        XCTAssertEqual(task.name, "Updated Name")
        XCTAssertNotEqual(task.modifiedAt, originalModifiedAt)
        XCTAssertFalse(self.context.hasChanges)
    }

    func testUpdateTask_WithEmptyName_ThrowsValidationError() throws {
        // Given
        let task = try taskService.createTask(name: "Valid Name", client: self.testClient, project: self.testProject)

        // When/Then
        XCTAssertThrowsError(try self.taskService.updateTask(task, name: "")) { error in
            XCTAssertTrue(error is TaskService.ValidationError)
        }
    }

    // MARK: - Delete Task Tests

    func testDeleteTask_WithExistingTask_DeletesSuccessfully() throws {
        // Given
        let task = try taskService.createTask(
            name: "Task to Delete",
            client: self.testClient,
            project: self.testProject
        )
        XCTAssertEqual(self.taskService.getTasks(for: self.testClient).count, 1)

        // When
        try self.taskService.deleteTask(task)

        // Then
        XCTAssertEqual(self.taskService.getTasks(for: self.testClient).count, 0)
        XCTAssertFalse(self.context.hasChanges)
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
