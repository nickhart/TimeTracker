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
    self.id = UUID()
    self.createdAt = Date()
    self.modifiedAt = Date()
  }

  override func willSave() {
    super.willSave()
    if !isInserted, isUpdated {
      self.modifiedAt = Date()
    }
  }
}
