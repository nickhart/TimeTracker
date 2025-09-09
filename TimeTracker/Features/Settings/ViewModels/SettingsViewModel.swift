//
//  SettingsViewModel.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/6/25.
//

import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    private let dataServices: DataServices

    @Published var autoPauseEnabled: Bool = false {
        didSet {
            self.settings?.autoPauseEnabled = self.autoPauseEnabled
        }
    }

    @Published var autoPauseMinutes: Int16 = 0 {
        didSet {
            self.settings?.autoPauseMinutes = self.autoPauseMinutes
        }
    }

    @Published var defaultBillingIncrement: Int16 = 0 {
        didSet {
            self.settings?.defaultBillingIncrement = self.defaultBillingIncrement
        }
    }

    @Published var defaultHourlyRate: Decimal = 0.0 {
        didSet {
            self.settings?.defaultHourlyRate = NSDecimalNumber(decimal: self.defaultHourlyRate)
        }
    }

    @Published var notificationSettings: Data?

    var settings: Settings?

    init(dataServices: DataServices) {
        self.dataServices = dataServices
        self.loadData()
    }

    private func loadData() {
        settings = try? self.dataServices.settingsService.getOrCreateSettings()
        if let settings = self.settings {
            self.autoPauseEnabled = settings.autoPauseEnabled
            self.autoPauseMinutes = settings.autoPauseMinutes
            self.defaultBillingIncrement = settings.defaultBillingIncrement
            self.defaultHourlyRate = settings.defaultHourlyRate?.decimalValue ?? 0.0
        }
    }

    func save() {
        try? self.dataServices.settingsService.save()
    }
}
