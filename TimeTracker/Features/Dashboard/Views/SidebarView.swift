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
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
  ) private var clients: FetchedResults<Client>
  @State private var selectedItem: SidebarItem? = .dashboard

  var body: some View {
    List(selection: self.$selectedItem) {
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
        ForEach(self.clients) { client in
          NavigationLink(value: SidebarItem.client(client)) {
            Label(client.name ?? "Unnamed", systemImage: "person.circle")
          }
        }
      }
    }
    .navigationTitle("TimeTracker")
  }
}

#Preview {
  SidebarView()
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
