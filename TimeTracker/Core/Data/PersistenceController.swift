//
//  PersistenceController.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData

// Empty marker that lives in the APP target (create if you don't already have one)
final class CoreDataModelMarker: NSObject {}

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample clients
        let acmeClient = Client(context: viewContext)
        acmeClient.name = "ACME Corp"
        acmeClient.hourlyRate = 150.0
        acmeClient.billingIncrement = 15
        acmeClient.notes = "Large corporate client - website and consulting work"

        let startupClient = Client(context: viewContext)
        startupClient.name = "Tech Startup Inc"
        startupClient.hourlyRate = 125.0
        startupClient.billingIncrement = 15
        startupClient.notes = "Growing startup - mobile app development"

        let freelanceClient = Client(context: viewContext)
        freelanceClient.name = "Local Business"
        freelanceClient.hourlyRate = 75.0
        freelanceClient.billingIncrement = 30

        // Create sample projects
        let websiteProject = Project(context: viewContext)
        websiteProject.name = "Website Redesign"
        websiteProject.client = acmeClient
        websiteProject.isActive = true
        websiteProject.hourlyRate = 160.0 // Override client rate

        let mobileProject = Project(context: viewContext)
        mobileProject.name = "Mobile App"
        mobileProject.client = startupClient
        mobileProject.isActive = true

        let consultingProject = Project(context: viewContext)
        consultingProject.name = "Tech Consulting"
        consultingProject.client = acmeClient
        consultingProject.isActive = false

        // Create sample tasks
        let calendar = Calendar.current
        let now = Date()

        // Completed tasks
        let completedTask1 = Task(context: viewContext)
        completedTask1.name = "Homepage Design"
        completedTask1.client = acmeClient
        completedTask1.project = websiteProject
        completedTask1.startTime = calendar.date(byAdding: .day, value: -2, to: now)
        completedTask1.endTime = calendar.date(byAdding: .hour, value: -46, to: now)
        completedTask1.duration = 7200 // 2 hours
        completedTask1.notes = "Initial homepage mockups and wireframes"

        let completedTask2 = Task(context: viewContext)
        completedTask2.name = "API Integration"
        completedTask2.client = startupClient
        completedTask2.project = mobileProject
        completedTask2.startTime = calendar.date(byAdding: .day, value: -1, to: now)
        completedTask2.endTime = calendar.date(byAdding: .hour, value: -2, to: now)
        completedTask2.duration = 10800 // 3 hours

        // Active/recent tasks
        let recentTask = Task(context: viewContext)
        recentTask.name = "Database Schema"
        recentTask.client = startupClient
        recentTask.project = mobileProject
        recentTask.startTime = calendar.date(byAdding: .hour, value: -1, to: now)
        recentTask.endTime = now
        recentTask.duration = 3600 // 1 hour

        // Tasks without projects (direct to client)
        let quickTask = Task(context: viewContext)
        quickTask.name = "Quick consultation call"
        quickTask.client = freelanceClient
        quickTask.startTime = calendar.date(byAdding: .hour, value: -3, to: now)
        quickTask.endTime = calendar.date(byAdding: .hour, value: -2, to: now)
        quickTask.duration = 1800 // 30 minutes

        let ongoingTask = Task(context: viewContext)
        ongoingTask.name = "Code Review"
        ongoingTask.client = acmeClient
        ongoingTask.startTime = calendar.date(byAdding: .minute, value: -45, to: now)
        // No endTime - currently active

        // Create sample settings
        let settings = Settings(context: viewContext)
        settings.defaultHourlyRate = 100.0
        settings.defaultBillingIncrement = 15
        settings.autoPauseEnabled = true
        settings.autoPauseMinutes = 5
        settings.notificationSettings = Data() // Empty for now

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        self.container = NSPersistentCloudKitContainer(name: "TimeTracker")
        if inMemory {
            self.container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        self.container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this
                // function
                // in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection
                 * when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
