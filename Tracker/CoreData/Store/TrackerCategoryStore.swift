//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Николай Замараев on 28.11.2025.
//

import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let results = try context.fetch(fetchRequest)
        
        if let existingCategory = results.first {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = title
            return newCategory
        }
    }
    
    func categoryTitle(for tracker: Tracker) -> String? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.category?.title
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
            return nil
        }
    }
    
    
    func fetchAllCategories() throws -> [String] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let results = try context.fetch(fetchRequest)
        return results.compactMap { $0.title }
    }
    
    func createCategory(with title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        _ = try context.fetch(fetchRequest)
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        
        try context.save()
    }
    
    func deleteCategory(_ category: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", category)
        
        let categories = try context.fetch(fetchRequest)
        
        if let categoryToDelete = categories.first {
            context.delete(categoryToDelete)
            CoreDataStore.shared.saveContext()
        }
    }
    
    func updateCategory(oldTitle: String, newTitle: String) throws {
        let checkRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        checkRequest.predicate = NSPredicate(format: "title = %@", newTitle)
        
        let existingCategory = try context.fetch(checkRequest)
        if !existingCategory.isEmpty && newTitle != oldTitle {
            throw NSError(domain: "TrackerCategoryStore", code: 409, userInfo: [
                NSLocalizedDescriptionKey: "Категория с таким названием уже существует"
            ])
        }
        
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", oldTitle)
        
        let categories = try context.fetch(fetchRequest)
        
        guard let categoryToUpdate = categories.first else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Категория не найдена"
            ])
        }
        
        categoryToUpdate.title = newTitle
        
        try context.save()
    }
}
