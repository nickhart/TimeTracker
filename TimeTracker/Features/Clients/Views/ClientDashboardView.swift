//
//  ClientDashboardView.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import SwiftUI

struct ClientDashboardView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Text("Client Dashboard View")
    }
}

#Preview {
    ClientDashboardView()
}
