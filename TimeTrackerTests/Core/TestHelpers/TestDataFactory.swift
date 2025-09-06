//
//  TestDataFactory.swift
//  TimeTrackerTests
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
@testable import TimeTracker

// swiftlint:disable large_tuple trailing_comma

/// Factory class for creating test data with realistic relationships and configurations
class TestDataFactory {
    private let context: NSManagedObjectContext
    private let dataServices: DataServices

    init(context: NSManagedObjectContext) {
        self.context = context
        self.dataServices = DataServices(context: context)
    }

    // MARK: - Client Factory Methods

    @discardableResult
    func createClient(name: String = "Test Client",
                      isActive: Bool = true,
                      hourlyRate: Decimal = 100.0,
                      billingIncrement: BillingIncrement = .fifteenMinutes) throws -> Client {
        let client = try dataServices.clientService.createClient(name: name)
        client.isActive = isActive
        client.hourlyRate = NSDecimalNumber(decimal: hourlyRate)
        client.billingIncrement = billingIncrement.rawValue
        try self.context.save()
        return client
    }

    func createMultipleClients(count: Int, activeRatio: Double = 0.8) throws -> [Client] {
        var clients: [Client] = []
        let activeCount = Int(Double(count) * activeRatio)

        for i in 1...count {
            let client = try createClient(
                name: "Client \(i)",
                isActive: i <= activeCount,
                hourlyRate: Decimal(50 + (i * 10)) // Varying hourly rates
            )
            clients.append(client)
        }

        return clients
    }

    // MARK: - Project Factory Methods

    @discardableResult
    func createProject(name: String = "Test Project",
                       for client: Client,
                       isActive: Bool = true,
                       hourlyRate: Decimal? = nil) throws -> Project {
        let project = try dataServices.projectService.createProject(for: client, name: name)
        project.isActive = isActive
        if let hourlyRate {
            project.hourlyRate = NSDecimalNumber(decimal: hourlyRate)
        }
        try self.context.save()
        return project
    }

    func createMultipleProjects(count: Int, for client: Client) throws -> [Project] {
        var projects: [Project] = []

        for i in 1...count {
            let project = try createProject(
                name: "Project \(i)",
                for: client,
                hourlyRate: i % 3 == 0 ? Decimal(150) : nil // Some projects override rates
            )
            projects.append(project)
        }

        return projects
    }

    // MARK: - Task Factory Methods

    @discardableResult
    func createTask(name: String = "Test Task",
                    client: Client,
                    project: Project? = nil,
                    isCompleted: Bool = false,
                    durationMinutes: Int? = nil) throws -> Task {
        let task = try dataServices.taskService.createTask(name: name, client: client, project: project)

        if isCompleted || durationMinutes != nil {
            try self.dataServices.taskService.startTimer(for: task)

            // If specific duration requested, adjust the start time
            if let minutes = durationMinutes {
                task.startTime = Date().addingTimeInterval(-TimeInterval(minutes * 60))
            } else {
                // Random duration between 15 minutes and 2 hours
                let randomMinutes = Int.random(in: 15...120)
                task.startTime = Date().addingTimeInterval(-TimeInterval(randomMinutes * 60))
            }

            try self.dataServices.taskService.stopTimer(for: task)
        }

        try self.context.save()
        return task
    }

    func createMultipleTasks(count: Int,
                             client: Client,
                             project: Project? = nil,
                             completedRatio: Double = 0.7) throws -> [Task] {
        var tasks: [Task] = []
        let completedCount = Int(Double(count) * completedRatio)

        for i in 1...count {
            let task = try createTask(
                name: "Task \(i)",
                client: client,
                project: project,
                isCompleted: i <= completedCount,
                durationMinutes: i <= completedCount ? Int.random(in: 15...240) : nil
            )
            tasks.append(task)
        }

        return tasks
    }

    // MARK: - Complex Scenario Factory Methods

    /// Creates a realistic client with projects and tasks
    func createClientWithFullHierarchy(clientName: String = "Full Test Client",
                                       projectCount: Int = 3,
                                       tasksPerProject: Int = 5) throws -> (Client, [Project], [Task]) {
        let client = try createClient(name: clientName)
        let projects = try createMultipleProjects(count: projectCount, for: client)

        var allTasks: [Task] = []
        for project in projects {
            let tasks = try createMultipleTasks(count: tasksPerProject, client: client, project: project)
            allTasks.append(contentsOf: tasks)
        }

        return (client, projects, allTasks)
    }

    /// Creates a running timer scenario
    func createRunningTimerScenario(clientName: String = "Active Client",
                                    projectName: String = "Active Project",
                                    taskName: String = "Running Task") throws -> (Client, Project, Task) {
        let client = try createClient(name: clientName)
        let project = try createProject(name: projectName, for: client)
        let task = try createTask(name: taskName, client: client, project: project)

        // Start the timer but don't stop it
        try dataServices.taskService.startTimer(for: task)

        return (client, project, task)
    }

    /// Creates billing test data with specific rates and durations
    func createBillingTestData() throws -> (Client, Project, [Task]) {
        let client = try createClient(
            name: "Billing Test Client",
            hourlyRate: 100.0,
            billingIncrement: .fifteenMinutes
        )

        let project = try createProject(
            name: "Premium Project",
            for: client,
            hourlyRate: 150.0 // Project overrides client rate
        )

        let tasks = try [
            createTask(name: "15min Task", client: client, project: project, isCompleted: true, durationMinutes: 15),
            createTask(name: "37min Task", client: client, project: project, isCompleted: true, durationMinutes: 37),
            createTask(name: "90min Task", client: client, project: project, isCompleted: true, durationMinutes: 90),
            createTask(name: "Incomplete Task", client: client, project: project, isCompleted: false),
        ]

        return (client, project, tasks)
    }

    // MARK: - Performance Test Data

    /// Creates large dataset for performance testing
    func createLargeDataset(clientCount: Int = 50,
                            projectsPerClient: Int = 10,
                            tasksPerProject: Int = 20) throws -> ([Client], [Project], [Task]) {
        var allClients: [Client] = []
        var allProjects: [Project] = []
        var allTasks: [Task] = []

        for i in 1...clientCount {
            let client = try createClient(name: "Perf Client \(i)")
            allClients.append(client)

            let projects = try createMultipleProjects(count: projectsPerClient, for: client)
            allProjects.append(contentsOf: projects)

            for project in projects {
                let tasks = try createMultipleTasks(count: tasksPerProject, client: client, project: project)
                allTasks.append(contentsOf: tasks)
            }

            // Save periodically to avoid memory issues
            if i % 10 == 0 {
                try self.context.save()
            }
        }

        try self.context.save()
        return (allClients, allProjects, allTasks)
    }

    // MARK: - Edge Case Data

    /// Creates data for testing edge cases
    func createEdgeCaseData() throws -> (Client, Project, [Task]) {
        let client = try createClient(name: "Edge Case Client")
        let project = try createProject(name: "Edge Case Project", for: client)

        let tasks = try [
            // Zero duration task
            createTask(name: "Zero Duration", client: client, project: project, isCompleted: true, durationMinutes: 0),
            // Very long task (24 hours)
            createTask(
                name: "24 Hour Task",
                client: client,
                project: project,
                isCompleted: true,
                durationMinutes: 1440
            ),
            // Task with special characters
            createTask(name: "Task w/ émojis 🕐 & spëcial chars!", client: client, project: project),
            // Task without project
            createTask(name: "No Project Task", client: client, project: nil),
        ]

        return (client, project, tasks)
    }
}

// MARK: - BillingIncrement Extension for Testing

extension BillingIncrement {
    static var allCases: [BillingIncrement] {
        [.oneMinute, .fiveMinutes, .fifteenMinutes, .thirtyMinutes, .oneHour]
    }
}

// swiftlint:enable large_tuple trailing_comma
