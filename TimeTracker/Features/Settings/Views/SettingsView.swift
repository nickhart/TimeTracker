//
//  SettingsView.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

// swiftlint:disable file_types_order

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    @State private var viewModel: SettingsViewModel?

    var body: some View {
        Group {
            if let viewModel {
                SettingsContent(viewModel: viewModel)
            } else {
                ProgressView("Loading Settings...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if let dataServices, viewModel == nil {
                dataServices.settingsService.ensureSettingsExist()
                self.viewModel = SettingsViewModel(dataServices: dataServices)
            }
        }
        .onDisappear {
            self.viewModel?.save()
        }
    }

    func saveSettings() {
        try? self.dataServices?.settingsService.save()
    }
}

struct SettingsContent: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Timer Settings") {
                Toggle("Auto-pause timer", isOn: self.$viewModel.autoPauseEnabled)

                if self.viewModel.autoPauseEnabled {
                    HStack {
                        Text("Auto-pause after")
                        Spacer()
                        TextField("Minutes", value: self.$viewModel.autoPauseMinutes, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("min")
                    }
                }
            }

            Section("Billing Defaults") {
                HStack {
                    Text("Default hourly rate")
                    Spacer()
                    TextField("Rate", value: self.$viewModel.defaultHourlyRate, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                Picker("Billing increment", selection: self.$viewModel.defaultBillingIncrement) {
                    Text("1 minute").tag(Int16(1))
                    Text("5 minutes").tag(Int16(5))
                    Text("10 minutes").tag(Int16(10))
                    Text("15 minutes").tag(Int16(15))
                    Text("30 minutes").tag(Int16(30))
                    Text("1 hour").tag(Int16(60))
                }
            }

            Section("Notifications") {
                Text("Notification settings")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// swiftlint:enable file_types_order

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let dataServices = DataServices(context: context)
    SettingsView()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, dataServices)
}
