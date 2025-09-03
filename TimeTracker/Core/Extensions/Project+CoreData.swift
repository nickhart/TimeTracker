//
//  Project+CoreData.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

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
