//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Николай Замараев on 28.11.2025.
//

import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(for trackerId: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        record.date = normalizedDate
        
        CoreDataStore.shared.saveContext()
    }
    
    func removeRecord(for trackerId: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        let results = try context.fetch(fetchRequest)
        if let recordToDelete = results.first {
            context.delete(recordToDelete)
            CoreDataStore.shared.saveContext()
        }
    }
    
    func fetchCompletedTrackers() -> Set<TrackerRecord> {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            var records = Set<TrackerRecord>()
            
            for recordCoreData in results {
                guard let trackerId = recordCoreData.trackerId,
                      let date = recordCoreData.date else {
                    continue
                }
                records.insert(TrackerRecord(trackerID: trackerId, date: date))
            }
            
            return records
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
            return []
        }
    }
    
    func completedDaysCount(for trackerId: UUID) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.count
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
            return false
        }
    }
    
    func perfectDaysCount() -> Int {
            let allRecords = fetchCompletedTrackers()
            let trackerStore = DataService.shared.trackerStore
            
            let allTrackers = trackerStore.fetchTrackers()
            
            guard !allTrackers.isEmpty else { return 0 }
            
            let calendar = Calendar.current
            var perfectDaysCount = 0
            
            var trackersByDate: [Date: Set<UUID>] = [:]
            
            for record in allRecords {
                let date = calendar.startOfDay(for: record.date)
                if trackersByDate[date] == nil {
                    trackersByDate[date] = []
                }
                trackersByDate[date]?.insert(record.trackerID)
            }
            
            for (date, completedTrackerIds) in trackersByDate {
                let scheduledTrackers = allTrackers.filter { tracker in
                    let weekdayComponent = calendar.component(.weekday, from: date)
                    guard let targetWeekday = Weekdays(calendarWeekday: weekdayComponent) else {
                        return false
                    }
                    return tracker.schedule.contains(targetWeekday)
                }
                
                if !scheduledTrackers.isEmpty {
                    let allCompleted = scheduledTrackers.allSatisfy { tracker in
                        completedTrackerIds.contains(tracker.id)
                    }
                    
                    if allCompleted {
                        perfectDaysCount += 1
                    }
                }
            }
            
            return perfectDaysCount
        }
    
    func longestStreak() -> Int {
            let allRecords = fetchCompletedTrackers()
            
            guard !allRecords.isEmpty else { return 0 }
            
            let sortedDates = allRecords.map { $0.date }.sorted()
            
            var longestStreak = 1
            var currentStreak = 1
            
            for i in 1..<sortedDates.count {
                let previousDate = sortedDates[i-1]
                let currentDate = sortedDates[i]
                
                if Calendar.current.isDate(previousDate, inSameDayAs: currentDate) {
                    continue
                }
                
                if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: previousDate),
                   Calendar.current.isDate(nextDay, inSameDayAs: currentDate) {
                    currentStreak += 1
                    longestStreak = max(longestStreak, currentStreak)
                } else {
                    currentStreak = 1
                }
            }
            
            return longestStreak
        }
    
    func averageTrackersPerDay() -> Int {
            let allRecords = fetchCompletedTrackers()
            
            guard !allRecords.isEmpty else { return 0 }
            
            let calendar = Calendar.current
            
            var trackersPerDay: [Date: Int] = [:]
            
            for record in allRecords {
                let date = calendar.startOfDay(for: record.date)
                trackersPerDay[date, default: 0] += 1
            }
            
            let totalTrackers = allRecords.count
            let totalDays = trackersPerDay.keys.count
            
            guard totalDays > 0 else { return 0 }
            
            return totalTrackers / totalDays
        }
}
