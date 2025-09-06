//
//  ClientsOverviewViewModel.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import CoreData
import SwiftUI

class ClientsOverviewViewModel: ObservableObject {
    @Environment(\.dataServices) private var dataServices

    @Published var totalClients: Int = 0
    @Published var activeClients: Int = 0

    init() {
        self.loadData()
    }

    private func loadData() {
        let all = self.dataServices?.clientService.fetchAllClients()
        let active = self.dataServices?.clientService.fetchAllClients()

        self.totalClients = all?.count ?? 0
        self.activeClients = active?.count ?? 0
    }
}
