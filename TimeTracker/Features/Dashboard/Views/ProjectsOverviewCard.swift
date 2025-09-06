//
//  ProjectsOverviewCard.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import SwiftUI

struct ProjectsOverviewCard: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Projects Overview Card")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ProjectsOverviewCard()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
