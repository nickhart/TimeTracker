//
//  ClientService.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import Foundation

class ClientService: ObservableObject, CoreDataServiceProtocol {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAllClients() -> [Client] {
        fetch(Client.self, sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)])
    }

    func hasClients() -> Bool {
        exists(Client.self)
    }

    func createClient(name: String, skipSave: Bool = false) throws -> Client {
        let client = Client(context: context)
        client.name = name

        try saveIfNeeded(skipSave: skipSave)
        return client
    }
}
