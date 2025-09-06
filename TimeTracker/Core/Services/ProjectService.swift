//
//  ProjectService.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

class ProjectService: ObservableObject, CoreDataServiceProtocol {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Global project queries
    func fetchAllProjects() -> [Project] {
        fetch(Project.self, sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)])
    }

    func hasProjects() -> Bool {
        exists(Project.self)
    }

    func hasProjects(for client: Client) -> Bool {
        exists(Project.self, predicate: NSPredicate(format: "client == %@", client))
    }

    // Client-specific project queries
    func fetchProjects(for client: Client) -> [Project] {
        fetch(
            Project.self,
            predicate: NSPredicate(format: "client == %@", client),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)]
        )
    }

    func fetchActiveProjects(for client: Client) -> [Project] {
        fetch(
            Project.self,
            predicate: NSPredicate(format: "client == %@ AND isActive == YES", client),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)]
        )
    }

    // Project creation/management
    func createProject(for client: Client, name: String, skipSave: Bool = false) throws -> Project {
        let project = Project(context: context)
        project.name = name
        project.client = client
        project.isActive = true
        try saveIfNeeded(skipSave: skipSave)
        return project
    }
}
