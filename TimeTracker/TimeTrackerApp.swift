//
//  TimeTrackerApp.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/2/25.
//

import SwiftUI

@main
struct TimeTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
