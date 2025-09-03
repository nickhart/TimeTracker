//
//  CoreDataTestHelpers.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
@testable import TimeTracker

extension Client {
    /// Creates a test Client with custom timestamps, bypassing awakeFromInsert
    static func createForTesting(context: NSManagedObjectContext,
                                 name: String = "Test Client",
                                 createdAt: Date = Date(timeIntervalSince1970: 1000),
                                 modifiedAt: Date = Date(timeIntervalSince1970: 1000)) -> Client {
        let client = Client(context: context)

        // Override the automatic timestamps with our test values
        client.name = name
        client.createdAt = createdAt
        client.modifiedAt = modifiedAt

        return client
    }
}

extension Project {
    /// Creates a test Project with custom timestamps, bypassing awakeFromInsert
    static func createForTesting(context: NSManagedObjectContext,
                                 name: String = "Test Project",
                                 createdAt: Date = Date(timeIntervalSince1970: 1000),
                                 modifiedAt: Date = Date(timeIntervalSince1970: 1000)) -> Project {
        let project = Project(context: context)

        project.name = name
        project.createdAt = createdAt
        project.modifiedAt = modifiedAt

        return project
    }
}

extension Task {
    /// Creates a test Task with custom timestamps, bypassing awakeFromInsert
    static func createForTesting(context: NSManagedObjectContext,
                                 name: String = "Test Task",
                                 createdAt: Date = Date(timeIntervalSince1970: 1000),
                                 modifiedAt: Date = Date(timeIntervalSince1970: 1000)) -> Task {
        let task = Task(context: context)

        task.name = name
        task.createdAt = createdAt
        task.modifiedAt = modifiedAt

        return task
    }
}
