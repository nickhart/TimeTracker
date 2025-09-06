//
//  TestConstants.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import Foundation
@testable import TimeTracker

/// Constants used across test suites for consistency
enum TestConstants {
    // MARK: - Default Test Names

    enum Names {
        static let client = "Test Client"
        static let project = "Test Project"
        static let task = "Test Task"

        static let activeClient = "Active Client"
        static let inactiveClient = "Inactive Client"

        static let runningTask = "Running Task"
        static let completedTask = "Completed Task"
        static let unstartedTask = "Unstarted Task"
    }

    // MARK: - Default Values

    enum Defaults {
        static let hourlyRate: Decimal = 100.0
        static let premiumHourlyRate: Decimal = 150.0
        static let budgetHourlyRate: Decimal = 75.0

        static let billingIncrement = BillingIncrement.fifteenMinutes
        static let shortBillingIncrement = BillingIncrement.oneMinute
        static let longBillingIncrement = BillingIncrement.oneHour

        static let taskDurationMinutes = 60
        static let shortTaskMinutes = 15
        static let longTaskMinutes = 240
    }

    // MARK: - Test Timeouts

    enum Timeouts {
        static let short: TimeInterval = 0.5
        static let medium: TimeInterval = 2.0
        static let long: TimeInterval = 5.0

        static let timer: TimeInterval = 1.5
        static let async: TimeInterval = 3.0
        static let performance: TimeInterval = 10.0
    }

    // MARK: - Test Counts

    enum Counts {
        static let small = 5
        static let medium = 25
        static let large = 100
        static let extraLarge = 500

        static let defaultClients = 3
        static let defaultProjectsPerClient = 5
        static let defaultTasksPerProject = 10
    }

    // MARK: - Test Dates

    enum Dates {
        /// Fixed date for consistent testing
        static let fixed = Date(timeIntervalSince1970: 1_000_000_000) // 2001-09-09 01:46:40 +0000

        /// One hour ago from fixed date
        static let oneHourAgo = fixed.addingTimeInterval(-3600)

        /// One hour after fixed date
        static let oneHourLater = fixed.addingTimeInterval(3600)

        /// One day ago from fixed date
        static let oneDayAgo = fixed.addingTimeInterval(-86400)

        /// One week ago from fixed date
        static let oneWeekAgo = fixed.addingTimeInterval(-604_800)
    }

    // MARK: - Performance Thresholds

    enum Performance {
        /// Maximum time for basic CRUD operations
        static let crudOperationThreshold: TimeInterval = 0.1

        /// Maximum time for complex queries
        static let queryThreshold: TimeInterval = 0.5

        /// Maximum time for ViewModel initialization
        static let viewModelInitThreshold: TimeInterval = 0.2

        /// Maximum time for bulk operations
        static let bulkOperationThreshold: TimeInterval = 2.0
    }

    // MARK: - Error Messages

    enum ErrorMessages {
        static let emptyName = "Name cannot be empty"
        static let taskNotRunning = "Task is not currently running"
        static let taskAlreadyRunning = "Task is already running"
        static let invalidClient = "Invalid client"
        static let invalidProject = "Invalid project"
    }

    // MARK: - Test Data Ratios

    enum Ratios {
        /// Percentage of clients that should be active in test datasets
        static let activeClients = 0.8

        /// Percentage of tasks that should be completed in test datasets
        static let completedTasks = 0.7

        /// Percentage of projects that should be active
        static let activeProjects = 0.9
    }

    // MARK: - Helper Methods

    /// Creates a unique name with timestamp for avoiding conflicts
    static func uniqueName(_ baseName: String) -> String {
        "\(baseName) \(Int(Date().timeIntervalSince1970))"
    }

    /// Creates a test client name with index
    static func clientName(index: Int) -> String {
        "Client \(index)"
    }

    /// Creates a test project name with index
    static func projectName(index: Int) -> String {
        "Project \(index)"
    }

    /// Creates a test task name with index
    static func taskName(index: Int) -> String {
        "Task \(index)"
    }

    /// Returns a random hourly rate between min and max
    static func randomHourlyRate(min: Decimal = 50, max: Decimal = 200) -> Decimal {
        let range = max - min
        let random = Decimal(Double.random(in: 0...1))
        return min + (range * random)
    }

    /// Returns a random task duration in minutes
    static func randomTaskDuration(min: Int = 15, max: Int = 240) -> Int {
        Int.random(in: min...max)
    }
}
