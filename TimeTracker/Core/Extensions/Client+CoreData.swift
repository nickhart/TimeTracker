//
//  Client+CoreData.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

// MARK: - CoreData lifecycle

public extension Client {
    override func awakeFromInsert() {
        super.awakeFromInsert()

        // Only set if not already set (allows manual override in tests)
        if self.id == nil {
            self.id = UUID()
        }

        let date = Date()
        if self.createdAt == nil {
            self.createdAt = date
        }
        if self.modifiedAt == nil {
            self.modifiedAt = date
        }
    }

    override func willSave() {
        super.willSave()
        if !isInserted, isUpdated {
            setPrimitiveValue(Date(), forKey: "modifiedAt")
        }
    }
}

// MARK: - computed properties

extension Client {
    var projectsArray: [Project] {
        let result = (projects?.allObjects as? [Project] ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }

        print("projects for \(self.name ?? "nil"): \(result.count)")
        return result
    }

    var tasksArray: [Task] {
        (tasks?.allObjects as? [Task] ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}

// MARK: - CustomStringConvertible

public extension Client {
    override var description: String { name ?? "Unnamed Client" }
}
