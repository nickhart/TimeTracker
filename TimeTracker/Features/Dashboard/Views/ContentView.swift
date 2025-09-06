//
//  ContentView.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import SwiftUI

// swiftlint:disable file_types_order type_name
struct ContentView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Group {
            if UIDevice.isPhone {
                iPhoneContentView()
                    .environment(\.dataServices, DataServices(context: self.context))
            } else {
                iPadContentView()
                    .environment(\.dataServices, DataServices(context: self.context))
            }
        }
    }
}

struct iPadContentView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        ZStack {
            NavigationSplitView {
                SidebarView()
            } detail: {
                RootDashboardView()
            }

            FloatingTimerWidget() // Floating over everything
        }
    }
}

struct iPhoneContentView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        VStack {
            NavigationStack {
                RootDashboardView()
            }

            TimerWidget() // Static at bottom
        }
    }
}

// swiftlint:enable file_types_order type_name

#Preview("ContentView - Adaptive") {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
