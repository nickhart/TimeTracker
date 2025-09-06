//
//  RecentActivityCard.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import SwiftUI

struct RecentActivityCard: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Recent Activity Card")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    RecentActivityCard()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
