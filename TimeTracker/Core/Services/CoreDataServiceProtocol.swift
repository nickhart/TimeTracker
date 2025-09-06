//
//  CoreDataServiceProtocol.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/5/25.
//

import CoreData

protocol CoreDataServiceProtocol {
    var context: NSManagedObjectContext { get }
}

extension CoreDataServiceProtocol {
    // MARK: - Save Operations

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    func saveIfNeeded(skipSave: Bool) throws {
        if !skipSave {
            try self.save()
        }
    }

    // MARK: - Fetch Operations

    func fetch<T: NSManagedObject>(_ type: T.Type,
                                   predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor] = []) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return (try? context.fetch(request)) ?? []
    }

    func count<T: NSManagedObject>(_ type: T.Type,
                                   predicate: NSPredicate? = nil) -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate

        // This is the key - count(for:) is super efficient!
        return (try? context.count(for: request)) ?? 0
    }

    func exists(_ type: (some NSManagedObject).Type, predicate: NSPredicate? = nil) -> Bool {
        self.count(type, predicate: predicate) > 0
    }
}
