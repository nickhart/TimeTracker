//
//  StatsViewModelTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import Combine
import CoreData
import XCTest
@testable import TimeTracker

class StatsViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var dataServices: DataServices!
    var viewModel: StatsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.context = PersistenceController.preview.container.viewContext
        self.dataServices = DataServices(context: self.context)
        self.cancellables = Set<AnyCancellable>()

        // Clear existing data
        try self.clearAllData()
    }

    override func tearDownWithError() throws {
        self.cancellables.removeAll()
        try self.clearAllData()
        self.viewModel = nil
        self.dataServices = nil
        self.context = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInitialization_CreatesViewModelSuccessfully() {
        // When
        self.viewModel = StatsViewModel()

        // Then
        XCTAssertNotNil(self.viewModel)
        // Since loadData() is empty, we just verify the ViewModel initializes without crashing
    }

    func testInitialization_CallsLoadData() {
        // Given/When
        self.viewModel = StatsViewModel()

        // Then
        // Since loadData() is currently empty, we can only verify initialization succeeds
        // In the future, when loadData() has actual implementation, we can verify its effects
        XCTAssertNotNil(self.viewModel)
    }

    // MARK: - ObservableObject Conformance Tests

    func testObservableObjectConformance() {
        // Given
        self.viewModel = StatsViewModel()

        // Then
        XCTAssertTrue(self.viewModel is ObservableObject)

        // Verify we can create a publisher (even if no @Published properties exist yet)
        let publisher = self.viewModel.objectWillChange
        XCTAssertNotNil(publisher)
    }

    // MARK: - Future Test Scaffolding

    // These tests provide scaffolding for when StatsViewModel gains more functionality

    func testLoadData_Integration() {
        // Given
        self.viewModel = StatsViewModel()

        // When loadData() gets implementation, test it here
        // For now, just verify no crash
        XCTAssertNotNil(self.viewModel)
    }

    func testStatsCalculation_WithTestData() {
        // This test will be relevant when StatsViewModel calculates actual statistics
        // Given
        let client = try? self.dataServices.clientService.createClient(name: "Test Client")
        let project = try? self.dataServices.projectService.createProject(for: client!, name: "Test Project")
        let task = try? self.dataServices.taskService.createTask(name: "Test Task", client: client!, project: project)

        // Simulate completed task
        if let task {
            try? self.dataServices.taskService.startTimer(for: task)
            Thread.sleep(forTimeInterval: 0.1) // Small delay
            try? self.dataServices.taskService.stopTimer(for: task)
        }

        // When
        self.viewModel = StatsViewModel()

        // Then
        // Future: Verify ViewModel calculates correct statistics from the test data
        XCTAssertNotNil(self.viewModel)
    }

    func testStatsUpdate_WhenDataChanges() {
        // Future test for when ViewModel responds to data changes
        // Given
        self.viewModel = StatsViewModel()

        // When data changes occur, verify stats update accordingly
        // This will test the reactive nature of the ViewModel
        XCTAssertNotNil(self.viewModel)
    }

    func testDataServices_Integration() {
        // This test will be relevant when the ViewModel properly uses DataServices
        // Given
        let client = try? self.dataServices.clientService.createClient(name: "Stats Test Client")
        XCTAssertNotNil(client)

        // When
        self.viewModel = StatsViewModel()

        // Then
        // Future: Verify ViewModel can access and process the data for statistics
        XCTAssertNotNil(self.viewModel)
    }

    // MARK: - Performance Tests

    func testInitialization_Performance() {
        // Measure initialization time, especially when loadData() becomes complex
        measure {
            let testViewModel = StatsViewModel()
            XCTAssertNotNil(testViewModel)
        }
    }

    func testStatsCalculation_Performance() {
        // Future test for stats calculation performance with large datasets
        // Given - Create a large dataset
        let client = try? self.dataServices.clientService.createClient(name: "Performance Test Client")

        for i in 1...100 {
            let project = try? self.dataServices.projectService.createProject(for: client!, name: "Project \(i)")
            let task = try? self.dataServices.taskService.createTask(
                name: "Task \(i)",
                client: client!,
                project: project
            )

            if let task {
                try? self.dataServices.taskService.startTimer(for: task)
                try? self.dataServices.taskService.stopTimer(for: task)
            }
        }

        // When/Then
        measure {
            let testViewModel = StatsViewModel()
            XCTAssertNotNil(testViewModel)
        }
    }

    // MARK: - Memory Management Tests

    func testMemoryManagement_NoRetainCycles() {
        // Given
        weak var weakViewModel: StatsViewModel?

        // When
        autoreleasepool {
            let strongViewModel = StatsViewModel()
            weakViewModel = strongViewModel
            XCTAssertNotNil(weakViewModel)
        }

        // Then
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated after going out of scope")
    }

    // MARK: - Error Handling Tests

    func testInitialization_WithoutCrash() {
        // Test that initialization doesn't crash even in edge cases

        for _ in 0..<10 {
            let testViewModel = StatsViewModel()
            XCTAssertNotNil(testViewModel)
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
