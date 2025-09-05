//
//  TimerWidget.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

struct TimerWidget: View {
    @StateObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField(
                    "Task name",
                    text: self.$viewModel.taskName,
                    prompt: Text("What's happening?").foregroundColor(.secondary)
                )
                Text(self.viewModel.elapsedTime.formattedDuration)
                Button(action: {
                    self.viewModel.toggleTimer()
                }, label: {
                    Image(systemName: self.viewModel.isRunning ? "stop.circle.fill" : "play.circle.fill")
                })
                .accessibilityLabel(self.viewModel.isRunning ? "Pause timer" : "Start timer")
                .accessibilityHint(self.viewModel
                    .isRunning ? "Pauses the current timer" : "Starts timing the current task"
                )
                .accessibilityIdentifier("timer-control-button")
            }
            HStack(spacing: 8) {
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
        .padding(8)
        .constrainedSize()
    }
}

extension View {
    func constrainedSize() -> some View {
        self.frame(maxWidth: UIDevice.isPhone ? .infinity : 450)
            .frame(maxHeight: 120)
    }
}

#Preview {
    let timerViewModel = TimerViewModel(context: PersistenceController.preview.container.viewContext)

    TimerWidget(viewModel: timerViewModel)
}
