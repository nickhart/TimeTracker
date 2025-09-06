//
//  RootDashboardView.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct RootDashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dataServices) private var dataServices

    var body: some View {
        VStack {
            HStack {
                Button("Add Client") { /* Create client */ }
                    .buttonStyle(.borderedProminent)

//                Button("New Project") { /* Create project */ }
//                    .buttonStyle(.bordered)
//                    .disabled(dataServices?.clientService.hasClients ?? false)
            }
            LazyVGrid(columns: self.adaptiveColumns, spacing: 16) {
                ClientsOverviewCard()
                ProjectsOverviewCard()
                RecentActivityCard()
                TimeStatsCard()
            }
            RecentTasksSection()
        }
    }

    private var adaptiveColumns: [GridItem] {
        if UIDevice.isPhone {
            // iPhone: Always 1 column (cards stack vertically)
            [GridItem(.flexible())]
        } else {
            // iPad: 2-3 columns depending on orientation/size
            Array(repeating: GridItem(.flexible(), spacing: 16), count: self.columnCount)
        }
    }

    private var columnCount: Int {
        // For iPad, adjust based on available width
        // This is a simplified approach - could use GeometryReader for precision
        if UIDevice.current.orientation.isLandscape {
            3 // Landscape iPad: 3 columns
        } else {
            2 // Portrait iPad: 2 columns
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    RootDashboardView()
        .environment(\.managedObjectContext, context)
        .environment(\.dataServices, DataServices(context: context))
}
