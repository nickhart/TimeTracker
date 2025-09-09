//
//  SettingsService.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/6/25.
//

import CoreData
import Foundation

class SettingsService: ObservableObject, CoreDataServiceProtocol {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func getOrCreateSettings(skipSave: Bool = false) throws -> Settings {
        if let existingSettings = try context.fetch(Settings.fetchRequest()).first {
            return existingSettings
        }
        let settings = Settings(context: context)
        settings.autoPauseEnabled = false
        settings.autoPauseMinutes = 15
        settings.defaultHourlyRate = 100
        settings.defaultBillingIncrement = 10

        try saveIfNeeded(skipSave: skipSave)
        return settings
    }

    func ensureSettingsExist() {
        _ = try? self.getOrCreateSettings()
    }
}
