//
//  StatsOverviewSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct StatsOverviewSection: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Stats Overview")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    StatsOverviewSection()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
