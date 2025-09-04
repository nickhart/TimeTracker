//
//  SelectionMenu.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

struct SelectionMenu<Item: Identifiable & CustomStringConvertible>: View {
    let title: String
    let items: [Item]
    @Binding var selectedItem: Item?
    let isEnabled: Bool

    init(title: String,
         items: [Item],
         selectedItem: Binding<Item?>,
         isEnabled: Bool = true) {
        self.title = title
        self.items = items
        self._selectedItem = selectedItem
        self.isEnabled = isEnabled
    }

    var body: some View {
        Menu {
            if self.items.isEmpty {
                Button("None available") {}
                    .disabled(true)
            } else {
                ForEach(self.items) { item in
                    Button(item.description) {
                        self.selectedItem = item
                    }
                }
                Divider()
                Button("None") {
                    self.selectedItem = nil
                }
            }
        } label: {
            HStack {
                Text(self.selectedItem?.description ?? self.title)
                    .foregroundColor(self.selectedItem == nil ? .secondary : .primary)
                Image(systemName: "chevron.up.chevron.down")
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!self.isEnabled)
    }
}

#Preview("Client Selection") {
    @Previewable @State var selectedClient: Client?

    let context = PersistenceController.preview.container.viewContext

    // Get clients from preview data
    let clientFetch: NSFetchRequest<Client> = Client.fetchRequest()
    let clients = (try? context.fetch(clientFetch)) ?? []

    return SelectionMenu(
        title: "Select Client",
        items: clients,
        selectedItem: $selectedClient
    )
    .padding()
}

#Preview("Project Selection") {
    @Previewable @State var selectedProject: Project?

    let context = PersistenceController.preview.container.viewContext

    // Get first client's projects for preview
    let clientFetch: NSFetchRequest<Client> = Client.fetchRequest()
    let firstClient = try? context.fetch(clientFetch).first
    let projects = firstClient?.projectsArray ?? []

    return SelectionMenu(
        title: "Select Project",
        items: projects,
        selectedItem: $selectedProject,
        isEnabled: !projects.isEmpty
    )
    .padding()
}

#Preview("Both Selectors") {
    @Previewable @State var selectedClient: Client?
    @Previewable @State var selectedProject: Project?

    let context = PersistenceController.preview.container.viewContext
    let clientFetch: NSFetchRequest<Client> = Client.fetchRequest()
    let clients = (try? context.fetch(clientFetch)) ?? []

    VStack {
        SelectionMenu(
            title: "Select Client",
            items: clients,
            selectedItem: $selectedClient
        )

        SelectionMenu(
            title: "Select Project",
            items: selectedClient?.projectsArray ?? [],
            selectedItem: $selectedProject,
            isEnabled: selectedClient != nil
        )
    }
    .padding()
}
