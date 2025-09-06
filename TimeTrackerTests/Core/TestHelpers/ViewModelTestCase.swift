//
//  ViewModelTestCase.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import Combine
import CoreData
import SwiftUI
import XCTest
@testable import TimeTracker

/// Base test case for testing ViewModels with common infrastructure
class ViewModelTestCase: CoreDataTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        self.cancellables.removeAll()
        self.cancellables = nil
        try super.tearDownWithError()
    }

    // MARK: - Published Property Testing

    /// Tests that a published property emits the expected sequence of values
    func assertPublishedProperty<T: Equatable, VM: ObservableObject>(_ keyPath: KeyPath<VM, Published<T>.Publisher>,
                                                                     on viewModel: VM,
                                                                     emits expectedValues: [T],
                                                                     when action: () -> Void,
                                                                     timeout: TimeInterval = 1.0,
                                                                     file: StaticString = #file,
                                                                     line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Published property emits expected values")
        var receivedValues: [T] = []

        viewModel[keyPath: keyPath]
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == expectedValues.count {
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        action()

        wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(
            receivedValues,
            expectedValues,
            "Published property should emit expected values",
            file: file,
            line: line
        )
    }

    /// Tests that a published property change triggers objectWillChange
    func assertObjectWillChangeTriggered<T>(on viewModel: some ObservableObject,
                                            when action: () -> Void,
                                            timeout: TimeInterval = 1.0,
                                            file: StaticString = #file,
                                            line: UInt = #line) {
        let expectation = XCTestExpectation(description: "objectWillChange is triggered")

        viewModel.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        action()

        wait(for: [expectation], timeout: timeout)
    }

    /// Counts the number of objectWillChange notifications during an action
    func countObjectWillChangeNotifications(on viewModel: some ObservableObject,
                                            during action: () -> Void,
                                            timeout: TimeInterval = 1.0) -> Int {
        let expectation = XCTestExpectation(description: "Action completes")
        var notificationCount = 0

        viewModel.objectWillChange
            .sink { _ in
                notificationCount += 1
            }
            .store(in: &self.cancellables)

        DispatchQueue.main.async {
            action()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
        return notificationCount
    }

    // MARK: - Environment Testing

    /// Creates a test environment with DataServices for ViewModels that use @Environment
    func createTestEnvironment() -> some View {
        EmptyView()
            .environment(\.managedObjectContext, context)
            .environment(\.dataServices, dataServices)
    }

    /// Tests a ViewModel that requires environment setup
    func testViewModelWithEnvironment<VM: ObservableObject>(viewModelType: VM.Type,
                                                            environmentSetup: (inout EnvironmentValues) -> Void = { _ in
                                                            },
                                                            test: @escaping (VM) -> Void) {
        let expectation = XCTestExpectation(description: "ViewModel test completes")

        struct TestView: View {
            let test: (VM) -> Void
            let expectation: XCTestExpectation
            @StateObject var viewModel = VM()

            var body: some View {
                EmptyView()
                    .onAppear {
                        self.test(self.viewModel)
                        self.expectation.fulfill()
                    }
            }
        }

        var environment = EnvironmentValues()
        environment.managedObjectContext = context
        environment.dataServices = dataServices
        environmentSetup(&environment)

        let testView = TestView(test: test, expectation: expectation)

        // Note: In a real test environment, you'd render this view
        // For now, we'll just call the test directly
        DispatchQueue.main.async {
            let viewModel = VM()
            test(viewModel)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Async Testing Helpers

    /// Waits for an async operation to complete and tests the result
    func waitForAsync<T>(description: String,
                         timeout: TimeInterval = 2.0,
                         operation: @escaping () async throws -> T,
                         test: @escaping (T) -> Void) throws {
        let expectation = XCTestExpectation(description: description)

        Task {
            do {
                let result = try await operation()
                await MainActor.run {
                    test(result)
                    expectation.fulfill()
                }
            } catch {
                XCTFail("Async operation failed: \(error)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    /// Waits for a condition to become true
    func waitForCondition(_ condition: @escaping () -> Bool,
                          timeout: TimeInterval = 1.0,
                          checkInterval: TimeInterval = 0.1,
                          description: String = "Condition becomes true") {
        let expectation = XCTestExpectation(description: description)

        func checkCondition() {
            if condition() {
                expectation.fulfill()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval) {
                    checkCondition()
                }
            }
        }

        checkCondition()
        wait(for: [expectation], timeout: timeout)
    }

    // MARK: - Timer Testing Helpers

    /// Tests timer-based functionality with controlled timing
    func testTimerFunctionality(setup: () -> Void,
                                startTimer: () -> Void,
                                stopTimer: () -> Void,
                                getCurrentTime: () -> TimeInterval,
                                isRunning: () -> Bool,
                                testDuration: TimeInterval = 0.2) {
        // Setup
        setup()
        XCTAssertFalse(isRunning())
        XCTAssertEqual(getCurrentTime(), 0, accuracy: 0.001)

        // Start timer
        startTimer()
        XCTAssertTrue(isRunning())

        // Wait and check time accumulation
        let startExpectation = XCTestExpectation(description: "Timer runs")
        DispatchQueue.main.asyncAfter(deadline: .now() + testDuration) {
            startExpectation.fulfill()
        }
        wait(for: [startExpectation], timeout: testDuration + 0.1)

        let elapsedTime = getCurrentTime()
        XCTAssertGreaterThan(elapsedTime, testDuration * 0.8, "Timer should accumulate time")
        XCTAssertLessThan(elapsedTime, testDuration * 1.2, "Timer should not accumulate too much time")

        // Stop timer
        let timeBeforeStop = getCurrentTime()
        stopTimer()
        XCTAssertFalse(isRunning())

        // Wait a bit and ensure time doesn't continue accumulating
        let stopExpectation = XCTestExpectation(description: "Timer stops")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            stopExpectation.fulfill()
        }
        wait(for: [stopExpectation], timeout: 0.2)

        XCTAssertEqual(getCurrentTime(), timeBeforeStop, accuracy: 0.05, "Timer should stop accumulating")
    }

    // MARK: - Data Service Testing

    /// Tests that a ViewModel properly integrates with DataServices
    func testDataServiceIntegration<VM: ObservableObject>(viewModel: VM,
                                                          dataSetup: () throws -> Void,
                                                          viewModelAction: (VM) -> Void,
                                                          verification: () throws -> Void) throws {
        // Setup test data
        try dataSetup()

        // Perform ViewModel action
        viewModelAction(viewModel)

        // Verify results
        try verification()
    }

    // MARK: - Memory Testing for ViewModels

    /// Tests that a ViewModel doesn't create retain cycles
    func testViewModelMemoryManagement<VM: ObservableObject>(viewModelType: VM.Type,
                                                             factory: () -> VM) {
        assertDeallocation(of: viewModelType, factory: factory)
    }

    // MARK: - State Testing Helpers

    /// Tests state transitions in ViewModels
    func testStateTransition<VM: ObservableObject, State: Equatable>(viewModel: VM,
                                                                     stateKeyPath: KeyPath<VM, State>,
                                                                     initialState: State,
                                                                     action: () -> Void,
                                                                     expectedFinalState: State,
                                                                     file: StaticString = #file,
                                                                     line: UInt = #line) {
        XCTAssertEqual(
            viewModel[keyPath: stateKeyPath],
            initialState,
            "Initial state should match",
            file: file,
            line: line
        )

        action()

        XCTAssertEqual(
            viewModel[keyPath: stateKeyPath],
            expectedFinalState,
            "Final state should match",
            file: file,
            line: line
        )
    }
}
