//
//  Project+CoreData.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

// MARK: - CoreData lifecycle

public extension Project {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        let date = Date()
        self.createdAt = date
        self.modifiedAt = date
    }

    override func willSave() {
        super.willSave()
        if !isInserted, isUpdated {
            setPrimitiveValue(Date(), forKey: "modifiedAt")
        }
    }
}

// MARK: - computed properties

extension Project {
    var tasksArray: [Task] {
        (tasks?.allObjects as? [Task] ?? [])
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}

// MARK: - CustomStringConvertible

public extension Project {
    override var description: String { name ?? "Unnamed Project" }
}
