//
//  TrackerStore.swift
//  Tracker
//
//  Created by Николай Замараев on 28.11.2025.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    
    private let colorMarshalling = ColorMarshalling()
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerCategoryStore: TrackerCategoryStore
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    init(context: NSManagedObjectContext, trackerCategoryStore: TrackerCategoryStore) {
        self.context = context
        self.trackerCategoryStore = trackerCategoryStore
        super.init()
    }
    
    func createTracker(_ tracker: Tracker, categoryTitle: String) throws {
        print("🟢 Создаем трекер: \(tracker.name), категория: \(categoryTitle)")
        
        guard context.persistentStoreCoordinator != nil else {
            print("🔴 Ошибка: контекст Core Data не готов")
            throw NSError(domain: "TrackerStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Контекст Core Data не готов"])
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        
        print("📝 Цвет сохранен как: \(colorMarshalling.hexString(from: tracker.color))")
        
        let scheduleData = try? NSKeyedArchiver.archivedData(withRootObject: tracker.schedule.map { $0.rawValue }, requiringSecureCoding: false)
        trackerCoreData.schedule = scheduleData
        
        print("📅 Расписание: \(tracker.schedule.map { $0.rawValue })")
        
        let category = try trackerCategoryStore.createCategory(with: categoryTitle)
        trackerCoreData.category = category
        
        print("📂 Категория создана: \(categoryTitle)")
        
        CoreDataStore.shared.saveContext()
        print("💾 Трекер сохранен в Core Data")
    }
    
    func fetchTrackers() -> [Tracker] {
        print("🔄 Загружаем трекеры из Core Data")
        guard let objects = fetchedResultController.fetchedObjects else {
            print("⚠️ Нет объектов в fetchedResultController")
            return []
        }
        
        print("📊 Найдено \(objects.count) трекеров в Core Data")
        
        var trackers: [Tracker] = []
        
        for trackerCoreData in objects {
            guard let id = trackerCoreData.id,
                  let name = trackerCoreData.name,
                  let colorHex = trackerCoreData.color,
                  let emoji = trackerCoreData.emoji else {
                print("⚠️ Пропускаем трекер с неполными данными")
                continue
            }
            
            print("📦 Трекер: \(name), цвет: \(colorHex), эмодзи: \(emoji)")
            
            var schedule: [Weekdays] = []
            if let scheduleData = trackerCoreData.schedule,
               let scheduleArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: scheduleData) as? [String] {
                schedule = scheduleArray.compactMap { Weekdays(rawValue: $0) }
            }
            
            let color = colorMarshalling.color(from: colorHex)
            
            let tracker = Tracker(
                id: id,
                name: name,
                color: color,
                schedule: schedule,
                emoji: emoji
            )
            trackers.append(tracker)
        }
        
        print("✅ Загружено \(trackers.count) трекеров")
        return trackers
    }
    
    func fetchTrackers(for date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekdayComponent = calendar.component(.weekday, from: date)
        guard let targetWeekday = Weekdays(calendarWeekday: weekdayComponent) else {
            return []
        }
        
        let allTrackers = fetchTrackers()
        var categories: [String: [Tracker]] = [:]
        
        for tracker in allTrackers {
            
            if tracker.schedule.contains(targetWeekday) {
                let categoryTitle = trackerCategoryStore.categoryTitle(for: tracker) ?? "Без категории"
                
                if categories[categoryTitle] == nil {
                    categories[categoryTitle] = []
                }
                categories[categoryTitle]?.append(tracker)
            }
        }
        
        let result = categories.map { TrackerCategory(title: $0.key, trackers: $0.value) }
            .sorted { $0.title < $1.title }
        
        return result
        
    }
    
    func deleteTrackers(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        if let trackerToDelete = results.first {
            context.delete(trackerToDelete)
            CoreDataStore.shared.saveContext()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
}
