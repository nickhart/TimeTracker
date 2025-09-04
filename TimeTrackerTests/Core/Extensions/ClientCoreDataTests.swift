//
//  ClientCoreDataTests.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Testing
@testable import TimeTracker

@Suite(.serialized)
final class ClientCoreDataTests {
    let container: NSPersistentContainer
    let context: NSManagedObjectContext

    init() {
        // Create in-memory Core Data stack for testing
        self.container = NSPersistentContainer(name: "TimeTracker")
        self.container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        var loadError: Error?
        self.container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            fatalError("Failed to load Core Data stack: \(error)")
        }

        self.context = self.container.viewContext
        self.context.automaticallyMergesChangesFromParent = true
    }

    @Test
    func clientCreationSetsTimestamps() async throws {
        let client = Client(context: context)
        #expect(client.id != nil)
        #expect(client.createdAt != nil)
        #expect(client.modifiedAt != nil)
    }

    @Test
    func modifiedAtUpdatesOnSave() async throws {
        let client = Client(context: context)

        // Set initial timestamps manually (bypassing awakeFromInsert behavior)
        let initialDate = Date(timeIntervalSince1970: 1000)
        client.createdAt = initialDate
        client.modifiedAt = initialDate
        client.name = "Initial Name"
        try self.context.save()

        // Verify initial state
        #expect(client.modifiedAt == initialDate)

        // Make a change and save
        client.name = "Updated Name"
        try self.context.save()

        // modifiedAt should now be newer than our initial date
        #expect(client.modifiedAt! > initialDate)
        #expect(client.createdAt == initialDate) // createdAt should not change
    }

    @Test
    func modifiedAtOnlyUpdatesOnActualChanges() async throws {
        let client = Client(context: context)

        // Set initial state
        let initialDate = Date(timeIntervalSince1970: 1000)
        client.createdAt = initialDate
        client.modifiedAt = initialDate
        client.name = "Test Client"
        try self.context.save()

        // Save again without changes
        try self.context.save()

        // modifiedAt should not have changed
        #expect(client.modifiedAt == initialDate)
    }

    @Test
    func clientDeletionCascadesToProjects() async throws {
        let client = Client(context: context)
        client.name = "Test Client"

        // Create associated projects
        let project1 = Project(context: context)
        project1.name = "Project 1"
        project1.client = client

        let project2 = Project(context: context)
        project2.name = "Project 2"
        project2.client = client

        try self.context.save()

        // Verify projects exist
        let projectFetch: NSFetchRequest<Project> = Project.fetchRequest()
        let projectsBefore = try context.fetch(projectFetch)
        #expect(projectsBefore.count == 2)

        // Delete the client
        self.context.delete(client)
        try self.context.save()

        // Verify projects were cascade deleted
        let projectsAfter = try context.fetch(projectFetch)
        #expect(projectsAfter.isEmpty)
    }

    @Test
    func clientDeletionCascadesToTasks() async throws {
        let client = Client(context: context)
        client.name = "Test Client"

        // Create tasks directly associated with client
        let task1 = Task(context: context)
        task1.name = "Direct Task 1"
        task1.client = client

        let task2 = Task(context: context)
        task2.name = "Direct Task 2"
        task2.client = client

        try self.context.save()

        // Verify tasks exist
        let taskFetch: NSFetchRequest<Task> = Task.fetchRequest()
        let tasksBefore = try context.fetch(taskFetch)
        #expect(tasksBefore.count == 2)

        // Delete the client
        self.context.delete(client)
        try self.context.save()

        // Verify tasks were cascade deleted
        let tasksAfter = try context.fetch(taskFetch)
        #expect(tasksAfter.isEmpty)
    }

    @Test
    func clientDeletionCascadesToProjectsAndTheirTasks() async throws {
        let client = Client(context: context)
        client.name = "Test Client"

        // Create project with tasks
        let project = Project(context: context)
        project.name = "Test Project"
        project.client = client

        let projectTask1 = Task(context: context)
        projectTask1.name = "Project Task 1"
        projectTask1.client = client
        projectTask1.project = project

        let projectTask2 = Task(context: context)
        projectTask2.name = "Project Task 2"
        projectTask2.client = client
        projectTask2.project = project

        // Also create a direct client task (no project)
        let directTask = Task(context: context)
        directTask.name = "Direct Client Task"
        directTask.client = client

        try self.context.save()

        // Verify everything exists
        let projectFetch: NSFetchRequest<Project> = Project.fetchRequest()
        let taskFetch: NSFetchRequest<Task> = Task.fetchRequest()

        #expect(try self.context.fetch(projectFetch).count == 1)
        #expect(try self.context.fetch(taskFetch).count == 3)

        // Delete the client
        self.context.delete(client)
        try self.context.save()

        // Verify everything was cascade deleted
        #expect(try self.context.fetch(projectFetch).isEmpty)
        #expect(try self.context.fetch(taskFetch).isEmpty)
    }

    @Test
    func projectDeletionNullifiesTasksButKeepsClient() async throws {
        let client = Client(context: context)
        client.name = "Test Client"

        let project = Project(context: context)
        project.name = "Test Project"
        project.client = client

        let task = Task(context: context)
        task.name = "Test Task"
        task.client = client
        task.project = project

        try self.context.save()

        // Delete the project
        self.context.delete(project)
        try self.context.save()

        // Verify client still exists
        #expect(!client.isDeleted)

        // Verify task still exists but project relationship is nullified
        #expect(!task.isDeleted)
        #expect(task.project == nil)
        #expect(task.client == client) // Client relationship should remain
    }
}
