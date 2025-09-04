//
//  TimerViewModel.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

class TimerViewModel: ObservableObject {
    @Published var currentTask: Task?
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var taskName: String = "" {
        didSet {
            self.currentTask?.name = self.taskName
            try? self.context.save()
        }
    }

    @Published var selectedClient: Client? {
        didSet {
            self.selectedProject = nil // Reset project when client changes
//            objectWillChange.send()
        }
    }

    @Published var selectedProject: Project?

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func toggleTimer() {
        if self.currentTask != nil {
            if self.isRunning {
                self.stopTimer()
            } else {
                self.startTimer()
            }
        }
    }

    func startTimer() {
        let task = Task(context: context)
//        task.client = client
//        task.project = project
        task.startTime = Date()

        try? self.context.save()
        self.currentTask = task
    }

    func stopTimer() {
        guard let task = currentTask else { return }
        task.endTime = Date()
        task.duration = Int64(task.endTime!.timeIntervalSince(task.startTime!))

        try? self.context.save()
    }

    var availableClients: [Client] {
        // Fetch all clients, sorted by name
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return (try? self.context.fetch(request)) ?? []
    }
}
