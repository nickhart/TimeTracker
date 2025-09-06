//
//  UnassignedTasksSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct UnassignedTasksSection: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Text("Unassigned Tasks Section")
    }
}

#Preview {
    UnassignedTasksSection()
}
