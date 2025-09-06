//
//  RootDashboardViewModel.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

class RootDashboardViewModel: ObservableObject {
    @Environment(\.dataServices) private var dataServices

    init() {
        self.loadData()
    }

    private func loadData() {}
}
