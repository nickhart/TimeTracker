//
//  ClientsOverviewCard.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import SwiftUI

struct ClientsOverviewCard: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    @StateObject private var viewModel = ClientsOverviewViewModel()

    var body: some View {
        Text("Clients Overview Card")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ClientsOverviewCard()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
