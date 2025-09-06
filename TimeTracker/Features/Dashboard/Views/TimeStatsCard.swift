//
//  TimeStatsCard.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import SwiftUI

struct TimeStatsCard: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        Text("Time Stats Card")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    TimeStatsCard()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
