//
//  DataService.swift
//  Tracker
//
//  Created by Николай Замараев on 07.12.2025.
//

import Foundation
import CoreData

final class DataService {
    static let shared = DataService()
    
    let context: NSManagedObjectContext
    let trackerCategoryStore: TrackerCategoryStore
    let trackerStore: TrackerStore
    let trackerRecordStore: TrackerRecordStore
    
    private init() {
        self.context = CoreDataStore.shared.viewContext
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerStore = TrackerStore(context: context, trackerCategoryStore: trackerCategoryStore)
        self.trackerRecordStore = TrackerRecordStore(context: context)
        
        print("✅ DataService инициализирован")
        print("📊 TrackerStore: \(trackerStore)")
        print("📊 TrackerRecordStore: \(trackerRecordStore)")
    }
}
