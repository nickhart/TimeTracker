//
//  TaskService.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

class TaskService: ObservableObject, CoreDataServiceProtocol {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func hasTasks() -> Bool {
        exists(Task.self)
    }

    func createTask(name: String, client: Client? = nil, project: Project? = nil,
                    skipSave: Bool = false) throws -> Task {
        let task = Task(context: context)
        task.name = name
        task.client = client
        task.project = project
        task.startTime = Date()

        try? saveIfNeeded(skipSave: skipSave)
        return task
    }

    func updateTask(_ task: Task, name: String? = nil, duration: TimeInterval? = nil, skipSave: Bool = false) {
        if let name {
            task.name = name
        }
        if let duration {
            task.duration = Int64(duration)
        }
        try? saveIfNeeded(skipSave: skipSave)
    }

    func completeTask(_ task: Task, skipSave: Bool = false) {
        task.endTime = Date()
        try? saveIfNeeded(skipSave: skipSave)
    }
}
