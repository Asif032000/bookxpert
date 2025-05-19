//
//  PersistenceController.swift
//  Bookxpert
//
//  Created by Asif Habib on 17/05/25.
//

import Foundation
import CoreData

//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    let container: NSPersistentContainer
//
//    init() {
//        container = NSPersistentContainer(name: "YourModelName") // Update this
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Unresolved error \(error)")
//            }
//        }
//    }
//}

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel") // Match .xcdatamodeld filename
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
