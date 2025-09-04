//
//  TimeTrackerApp.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

@main
struct TimeTrackerApp: App {
    let persistenceController = PersistenceController.shared

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
                    TimerWidget(context: self.persistenceController.container.viewContext)
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
                    FloatingTimerWidget()
                }
            }
        }
    }
}
