//
//  RecentTasksSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct RecentTasksSection: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Recent Tasks")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    RecentTasksSection()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
