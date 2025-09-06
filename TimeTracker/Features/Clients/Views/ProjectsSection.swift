//
//  ProjectsSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct ProjectsSection: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Text("Client Projects Section")
    }
}

#Preview {
    ProjectsSection()
}
