//
//  ActiveProjectsSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct ActiveProjectsSection: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Active Projects")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ActiveProjectsSection()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
