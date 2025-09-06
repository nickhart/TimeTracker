//
//  DataServices.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import CoreData
import SwiftUI

// swiftlint:disable file_types_order
class DataServices {
    let clientService: ClientService
    let projectService: ProjectService
    let taskService: TaskService
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        self.clientService = ClientService(context: context)
        self.projectService = ProjectService(context: context)
        self.taskService = TaskService(context: context)
    }

    // Coordinated operations with single save
    func createProjectWithTask(client: Client, projectName: String, taskName: String) throws -> (Project, Task) {
        let project = try projectService.createProject(for: client, name: projectName, skipSave: true)
        let task = try taskService.createTask(name: taskName, client: client, project: project, skipSave: true)
        try self.context.save() // Single save for both
        return (project, task)
    }

    func save() throws {
        if self.context.hasChanges {
            try self.context.save()
        }
    }
}

// MARK: - Environment support

struct DataServicesKey: EnvironmentKey {
    static let defaultValue: DataServices? = nil
}

extension EnvironmentValues {
    var dataServices: DataServices? {
        get { self[DataServicesKey.self] }
        set { self[DataServicesKey.self] = newValue }
    }
}

// swiftlint:enable file_types_order
