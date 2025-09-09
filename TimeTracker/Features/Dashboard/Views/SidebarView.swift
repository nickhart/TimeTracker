//
//  SidebarView.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

enum SidebarItem: Hashable {
    case dashboard
    case settings
    case client(Client)
}

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    @Binding var selection: SidebarItem?

    var body: some View {
        List(selection: self.$selection) {
            // Always-present navigation items
            Section {
                NavigationLink(value: SidebarItem.dashboard) {
                    Label("Dashboard", systemImage: "house")
                }
                NavigationLink(value: SidebarItem.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }

            // Clients section
            Section("Clients") {
//                ForEach(self.clients) { client in
//                    NavigationLink(value: SidebarItem.client(client)) {
//                        Label(client.name ?? "Unnamed", systemImage: "person.circle")
//                    }
//                }
            }
        }
        .navigationTitle("TimeTracker")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    SidebarView(selection: .constant(.dashboard))
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
