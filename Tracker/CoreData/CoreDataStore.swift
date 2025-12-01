//
//  CoreDataStore.swift
//  Tracker
//
//  Created by Николай Замараев on 28.11.2025.
//

import Foundation
import CoreData

final class CoreDataStore {
    
    static let shared = CoreDataStore()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                //Код для обработки ошибок
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private init() {}
}

