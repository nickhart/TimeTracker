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
        }
    }

    @Published var selectedProject: Project?

    private var timer: Timer?
    private var startTime: Date?
    private var duration: TimeInterval = 0
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Timer Control

    func toggleTimer() {
        if self.isRunning {
            self.stopTimer()
        } else {
            self.startTimer()
        }
    }

    func startTimer() {
        guard !self.isRunning else { return }
//        let task = Task(context: context)
//        task.client = client
//        task.project = project
//        task.startTime = Date()

//        try? self.context.save()
//        self.currentTask = task

        self.startTime = Date()
        self.isRunning = true

        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    func stopTimer() {
        guard self.isRunning else { return }
//        guard let task = currentTask else { return }
//        task.endTime = Date()
//        task.duration = Int64(task.endTime!.timeIntervalSince(task.startTime!))
//
//        try? self.context.save()

        if let startTime {
            self.duration += Date().timeIntervalSince(startTime)
        }
        self.timer?.invalidate()
        self.timer = nil
        self.isRunning = false
        startTime = nil
    }

    private func updateElapsedTime() {
        guard let startTime else { return }
        self.elapsedTime = Date().timeIntervalSince(startTime) + self.duration
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - CoreData helpers

    var availableClients: [Client] {
        // Fetch all clients, sorted by name
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return (try? self.context.fetch(request)) ?? []
    }
}
