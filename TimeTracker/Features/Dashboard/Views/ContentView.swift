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
                    .environment(\.managedObjectContext, self.context)
                    .environment(\.dataServices, DataServices(context: self.context))
            } else {
                iPadContentView()
                    .environment(\.managedObjectContext, self.context)
                    .environment(\.dataServices, DataServices(context: self.context))
            }
        }
    }
}

struct iPadContentView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    @State private var selection: SidebarItem? = .dashboard

    var body: some View {
        ZStack {
            NavigationSplitView {
                SidebarView(selection: self.$selection)
            } detail: {
                switch self.selection {
                case .dashboard:
                    RootDashboardView()
                case .settings:
                    SettingsView()
//                case .client(let client):
//                    ClientDashboardView(client: client)
                default:
                    RootDashboardView() // Default
                }
            }
            .environment(\.managedObjectContext, self.context)
            .environment(\.dataServices, self.dataServices)

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
            .environment(\.managedObjectContext, self.context)
            .environment(\.dataServices, self.dataServices)

            TimerWidget() // Static at bottom
        }
    }
}

// swiftlint:enable file_types_order type_name

#Preview("ContentView - Adaptive") {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
