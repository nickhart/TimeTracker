//
//  Client+CoreData.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

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
