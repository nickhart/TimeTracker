//
//  RootDashboardViewModelTests.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import Combine
import CoreData
import XCTest
@testable import TimeTracker

class RootDashboardViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var dataServices: DataServices!
    var viewModel: RootDashboardViewModel!
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
        self.viewModel = RootDashboardViewModel()

        // Then
        XCTAssertNotNil(self.viewModel)
        // Since loadData() is empty, we just verify the ViewModel initializes without crashing
    }

    func testInitialization_CallsLoadData() {
        // Given/When
        self.viewModel = RootDashboardViewModel()

        // Then
        // Since loadData() is currently empty, we can only verify initialization succeeds
        // In the future, when loadData() has actual implementation, we can verify its effects
        XCTAssertNotNil(self.viewModel)
    }

    // MARK: - ObservableObject Conformance Tests

    func testObservableObjectConformance() {
        // Given
        self.viewModel = RootDashboardViewModel()

        // Then
        XCTAssertTrue(self.viewModel is ObservableObject)

        // Verify we can create a publisher (even if no @Published properties exist yet)
        let publisher = self.viewModel.objectWillChange
        XCTAssertNotNil(publisher)
    }

    // MARK: - Future Test Scaffolding

    // These tests provide scaffolding for when RootDashboardViewModel gains more functionality

    func testLoadData_Integration() {
        // Given
        self.viewModel = RootDashboardViewModel()

        // When loadData() gets implementation, test it here
        // For now, just verify no crash
        XCTAssertNotNil(self.viewModel)
    }

    func testDataServices_Integration() {
        // This test will be relevant when the ViewModel properly uses DataServices
        // Given
        let client = try? self.dataServices.clientService.createClient(name: "Test Client")
        XCTAssertNotNil(client)

        // When
        self.viewModel = RootDashboardViewModel()

        // Then
        // Future: Verify ViewModel can access and use the data
        XCTAssertNotNil(self.viewModel)
    }

    // MARK: - Memory Management Tests

    func testMemoryManagement_NoRetainCycles() {
        // Given
        weak var weakViewModel: RootDashboardViewModel?

        // When
        autoreleasepool {
            let strongViewModel = RootDashboardViewModel()
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
            let testViewModel = RootDashboardViewModel()
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
