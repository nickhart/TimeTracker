//
//  TimerViewModelTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import Combine
import CoreData
import XCTest
@testable import TimeTracker

class TimerViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var dataServices: DataServices!
    var viewModel: TimerViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.dataServices = DataServices(context: self.context)
        self.viewModel = TimerViewModel()
        self.cancellables = Set<AnyCancellable>()

        // Clear existing data
        try self.clearAllData()
    }

    override func tearDownWithError() throws {
        self.viewModel.stopTimer() // Ensure timer is stopped
        self.cancellables.removeAll()
        try self.clearAllData()
        self.viewModel = nil
        self.dataServices = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInitialization_SetsDefaultValues() {
        // Then
        XCTAssertNil(self.viewModel.currentTask)
        XCTAssertEqual(self.viewModel.elapsedTime, 0)
        XCTAssertFalse(self.viewModel.isRunning)
        XCTAssertEqual(self.viewModel.taskName, "")
        XCTAssertNil(self.viewModel.selectedClient)
        XCTAssertNil(self.viewModel.selectedProject)
    }

    // MARK: - Timer Control Tests

    func testStartTimer_WhenNotRunning_StartsTimer() {
        // Given
        XCTAssertFalse(self.viewModel.isRunning)

        // When
        self.viewModel.startTimer()

        // Then
        XCTAssertTrue(self.viewModel.isRunning)
    }

    func testStartTimer_WhenAlreadyRunning_DoesNothing() {
        // Given
        self.viewModel.startTimer()
        XCTAssertTrue(self.viewModel.isRunning)

        // When
        self.viewModel.startTimer() // Try to start again

        // Then
        XCTAssertTrue(self.viewModel.isRunning) // Still running, no change
    }

    func testStopTimer_WhenRunning_StopsTimer() {
        // Given
        self.viewModel.startTimer()
        XCTAssertTrue(self.viewModel.isRunning)

        // When
        self.viewModel.stopTimer()

        // Then
        XCTAssertFalse(self.viewModel.isRunning)
    }

    func testStopTimer_WhenNotRunning_DoesNothing() {
        // Given
        XCTAssertFalse(self.viewModel.isRunning)

        // When
        self.viewModel.stopTimer()

        // Then
        XCTAssertFalse(self.viewModel.isRunning) // Still not running
    }

    func testToggleTimer_WhenNotRunning_StartsTimer() {
        // Given
        XCTAssertFalse(self.viewModel.isRunning)

        // When
        self.viewModel.toggleTimer()

        // Then
        XCTAssertTrue(self.viewModel.isRunning)
    }

    func testToggleTimer_WhenRunning_StopsTimer() {
        // Given
        self.viewModel.startTimer()
        XCTAssertTrue(self.viewModel.isRunning)

        // When
        self.viewModel.toggleTimer()

        // Then
        XCTAssertFalse(self.viewModel.isRunning)
    }

    // MARK: - Elapsed Time Tests

    func testElapsedTime_UpdatesWhileRunning() {
        // Given
        let expectation = XCTestExpectation(description: "Elapsed time updates")
        var timeUpdates = 0

        self.viewModel.$elapsedTime
            .sink { _ in
                timeUpdates += 1
                if timeUpdates > 1 { // Skip initial value
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        // When
        self.viewModel.startTimer()

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertGreaterThan(self.viewModel.elapsedTime, 0)
    }

    func testElapsedTime_StopsUpdatingWhenTimerStopped() {
        // Given
        self.viewModel.startTimer()

        // Wait for some elapsed time
        let startExpectation = XCTestExpectation(description: "Timer starts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: 1.0)

        let elapsedTimeBeforeStop = self.viewModel.elapsedTime
        XCTAssertGreaterThan(elapsedTimeBeforeStop, 0)

        // When
        self.viewModel.stopTimer()

        // Wait a bit more
        let stopExpectation = XCTestExpectation(description: "Timer stops")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            stopExpectation.fulfill()
        }
        wait(for: [stopExpectation], timeout: 1.0)

        // Then
        XCTAssertEqual(self.viewModel.elapsedTime, elapsedTimeBeforeStop, accuracy: 0.1)
    }

    // MARK: - Client/Project Selection Tests

    func testSelectedClient_ChangesSelectedProject() {
        // Given
        // Note: This test assumes DataServices would be properly injected in a real scenario
        // For now, we're testing the property change behavior

        self.viewModel.selectedProject = Project.createForTesting(context: self.context, name: "Some Project")

        // When
        self.viewModel.selectedClient = Client.createForTesting(context: self.context, name: "New Client")

        // Then
        XCTAssertNil(self.viewModel.selectedProject, "Selected project should be reset when client changes")
    }

    // MARK: - Task Name Tests

    func testTaskName_PropertyChanges() {
        // When
        self.viewModel.taskName = "New Task Name"

        // Then
        XCTAssertEqual(self.viewModel.taskName, "New Task Name")
    }

    // MARK: - Available Clients Tests

    func testAvailableClients_WithNoDataServices_ReturnsEmptyArray() {
        // Given/When
        let clients = self.viewModel.availableClients

        // Then
        XCTAssertEqual(clients.count, 0)
    }

    // MARK: - Memory Management Tests

    func testDeinit_InvalidatesTimer() {
        // Given
        self.viewModel.startTimer()
        XCTAssertTrue(self.viewModel.isRunning)

        // When
        self.viewModel = nil

        // Then - No assertion needed, just ensuring no memory leaks or crashes
        // The deinit should invalidate the timer properly
    }

    // MARK: - Timer Persistence Tests

    func testElapsedTime_AccumulatesAcrossMultipleStartStop() {
        // Given
        self.viewModel.startTimer()

        // Wait for some time
        let firstRunExpectation = XCTestExpectation(description: "First run")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            firstRunExpectation.fulfill()
        }
        wait(for: [firstRunExpectation], timeout: 1.0)

        let timeAfterFirstRun = self.viewModel.elapsedTime
        self.viewModel.stopTimer()

        // Start timer again
        self.viewModel.startTimer()

        // Wait for more time
        let secondRunExpectation = XCTestExpectation(description: "Second run")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            secondRunExpectation.fulfill()
        }
        wait(for: [secondRunExpectation], timeout: 1.0)

        // Then
        XCTAssertGreaterThan(
            self.viewModel.elapsedTime,
            timeAfterFirstRun,
            "Elapsed time should accumulate across starts/stops"
        )
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
