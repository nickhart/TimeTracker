//
//  CoreDataTestCase.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import XCTest
@testable import TimeTracker

/// Base test case class that provides common CoreData testing infrastructure
class CoreDataTestCase: XCTestCase {
    var context: NSManagedObjectContext!
    var dataServices: DataServices!
    var testDataFactory: TestDataFactory!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.dataServices = DataServices(context: self.context)
        self.testDataFactory = TestDataFactory(context: self.context)

        // Clear any existing data
        try self.clearAllTestData()
    }

    override func tearDownWithError() throws {
        try self.clearAllTestData()
        self.testDataFactory = nil
        self.dataServices = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Data Management

    /// Clears all test data from the context
    func clearAllTestData() throws {
        try self.clearEntity("Task")
        try self.clearEntity("Project")
        try self.clearEntity("Client")
        try self.context.save()
    }

    /// Clears all instances of a specific entity
    private func clearEntity(_ entityName: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
    }

    // MARK: - Assertion Helpers

    /// Asserts that a client has the expected number of projects
    func assertClientHasProjects(_ client: Client, count: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(
            client.projects?.count ?? 0,
            count,
            "Client should have \(count) projects",
            file: file,
            line: line
        )
    }

    /// Asserts that a client has the expected number of tasks
    func assertClientHasTasks(_ client: Client, count: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(client.tasks?.count ?? 0, count, "Client should have \(count) tasks", file: file, line: line)
    }

    /// Asserts that a project has the expected number of tasks
    func assertProjectHasTasks(_ project: Project, count: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(project.tasks?.count ?? 0, count, "Project should have \(count) tasks", file: file, line: line)
    }

    /// Asserts that a task is properly completed (has both start and end times)
    func assertTaskIsCompleted(_ task: Task, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(task.startTime, "Completed task should have start time", file: file, line: line)
        XCTAssertNotNil(task.endTime, "Completed task should have end time", file: file, line: line)
        if let startTime = task.startTime, let endTime = task.endTime {
            XCTAssertGreaterThanOrEqual(
                endTime,
                startTime,
                "End time should be after start time",
                file: file,
                line: line
            )
        }
    }

    /// Asserts that a task is currently running (has start time but no end time)
    func assertTaskIsRunning(_ task: Task, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(task.startTime, "Running task should have start time", file: file, line: line)
        XCTAssertNil(task.endTime, "Running task should not have end time", file: file, line: line)
    }

    /// Asserts that a task has not been started
    func assertTaskNotStarted(_ task: Task, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(task.startTime, "Unstarted task should not have start time", file: file, line: line)
        XCTAssertNil(task.endTime, "Unstarted task should not have end time", file: file, line: line)
    }

    /// Asserts that context has no unsaved changes
    func assertContextIsSaved(file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.context.hasChanges, "Context should have no unsaved changes", file: file, line: line)
    }

    /// Asserts that context has unsaved changes
    func assertContextHasChanges(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.context.hasChanges, "Context should have unsaved changes", file: file, line: line)
    }

    // MARK: - Timing Helpers

    /// Waits for a small amount of time to ensure timestamps are different
    func waitForTimestampDifference() {
        Thread.sleep(forTimeInterval: 0.01)
    }

    /// Creates a date in the past by the specified number of minutes
    func dateMinutesAgo(_ minutes: Int) -> Date {
        Date().addingTimeInterval(-TimeInterval(minutes * 60))
    }

    /// Creates a date in the future by the specified number of minutes
    func dateMinutesFromNow(_ minutes: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(minutes * 60))
    }

    // MARK: - Performance Testing Helpers

    /// Measures the execution time of a block and asserts it's under a threshold
    func assertPerformance<T>(_ description: String,
                              expectedTimeThreshold: TimeInterval = 1.0,
                              block: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertLessThan(
            timeElapsed,
            expectedTimeThreshold,
            "\(description) took \(timeElapsed)s, expected < \(expectedTimeThreshold)s"
        )

        return result
    }

    // MARK: - Data Verification Helpers

    /// Verifies that the database is in a consistent state
    func verifyDatabaseConsistency() throws {
        let allClients = self.dataServices.clientService.getAllClients()
        let allProjects = self.dataServices.projectService.getAllProjects()
        let allTasks = self.dataServices.taskService.fetch(Task.self)

        // Verify all projects belong to existing clients
        for project in allProjects {
            XCTAssertNotNil(project.client, "Project '\(project.name ?? "unnamed")' should have a client")
            XCTAssertTrue(allClients.contains(project.client!), "Project's client should be in clients list")
        }

        // Verify all tasks belong to existing clients
        for task in allTasks {
            XCTAssertNotNil(task.client, "Task '\(task.name ?? "unnamed")' should have a client")
            XCTAssertTrue(allClients.contains(task.client!), "Task's client should be in clients list")

            // If task has a project, verify it belongs to the same client
            if let project = task.project {
                XCTAssertTrue(allProjects.contains(project), "Task's project should be in projects list")
                XCTAssertEqual(task.client, project.client, "Task and its project should have the same client")
            }
        }

        // Verify completed tasks have valid time ranges
        let completedTasks = allTasks.filter { $0.startTime != nil && $0.endTime != nil }
        for task in completedTasks {
            self.assertTaskIsCompleted(task)
        }

        // Verify running tasks have only start time
        let runningTasks = allTasks.filter { $0.startTime != nil && $0.endTime == nil }
        for task in runningTasks {
            self.assertTaskIsRunning(task)
        }
    }

    // MARK: - Memory Testing Helpers

    /// Tests that an object is properly deallocated
    func assertDeallocation<T: AnyObject>(of objectType: T.Type,
                                          factory: () -> T) {
        weak var weakReference: T?

        autoreleasepool {
            let strongReference = factory()
            weakReference = strongReference
            XCTAssertNotNil(weakReference)
        }

        XCTAssertNil(weakReference, "\(objectType) should be deallocated after going out of scope")
    }
}
