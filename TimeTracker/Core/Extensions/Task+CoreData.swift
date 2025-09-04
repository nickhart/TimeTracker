//
//  Task+CoreData.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

// MARK: - CoreData lifecycle

public extension Task {
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

// MARK: - CustomStringConvertible

public extension Task {
    override var description: String { name ?? "Unnamed Task" }
}
