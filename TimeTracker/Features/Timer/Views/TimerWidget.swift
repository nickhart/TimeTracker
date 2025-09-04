//
//  TimerWidget.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

struct TimerWidget: View {
    @StateObject private var viewModel: TimerViewModel

    init(context: NSManagedObjectContext) {
        self._viewModel = StateObject(wrappedValue: TimerViewModel(context: context))
    }

    var body: some View {
        VStack {
            HStack {
                TextField(
                    "Task name",
                    text: self.$viewModel.taskName,
                    prompt: Text("What's happening?").foregroundColor(.secondary)
                )
                Button(self.viewModel.isRunning ? "Stop" : "Start") {
                    self.viewModel.toggleTimer()
                }
            }
            HStack {
                SelectionMenu(
                    title: "Select Client",
                    items: self.viewModel.availableClients,
                    selectedItem: self.$viewModel.selectedClient
                )

                SelectionMenu(
                    title: "Select Project",
                    items: self.viewModel.selectedClient?.projectsArray ?? [],
                    selectedItem: self.$viewModel.selectedProject,
                    isEnabled: self.viewModel.selectedClient != nil
                )
            }
        }
    }
}

#Preview {
    TimerWidget(context: PersistenceController.preview.container.viewContext)
}
