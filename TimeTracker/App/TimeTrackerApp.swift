//
//  TimeTrackerApp.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

@main
struct TimeTrackerApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var timerViewModel = TimerViewModel(
        context: PersistenceController.shared.container.viewContext
    )

    var body: some Scene {
        WindowGroup {
            if UIDevice.isPhone {
                VStack {
                    NavigationSplitView {
                        SidebarView()
                    }
                    detail: {
                        RootDashboardView()
                            .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
                    }
                    TimerWidget(viewModel: self.timerViewModel)
                }
            } else {
                ZStack {
                    NavigationSplitView {
                        SidebarView()
                    }
                    detail: {
                        RootDashboardView()
                            .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
                    }
                    FloatingTimerWidget(viewModel: self.timerViewModel)
                }
            }
        }
    }
}
