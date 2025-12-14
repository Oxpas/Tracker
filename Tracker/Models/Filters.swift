//
//  Filters.swift
//  Tracker
//
//  Created by Николай Замараев on 14.12.2025.
//

enum Filters: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completedTrackers = "Завершенные"
    case uncompletedTrackers = "Незавершенные"
}
