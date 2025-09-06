//
//  ClientStatsSection.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct ClientStatsSection: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Text("Client Stats Section")
    }
}

#Preview {
    ClientStatsSection()
}
