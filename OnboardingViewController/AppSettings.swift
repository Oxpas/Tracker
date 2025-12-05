//
//  AppSeting.swift
//  Tracker
//
//  Created by Николай Замараев on 05.12.2025.
//

import Foundation

enum AppSettings {
    
    private static let isFirstOpenKey = "isFirstAppOpen"
    
    static var isFirstAppOpen: Bool {
            get {
                UserDefaults.standard.bool(forKey: isFirstOpenKey)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: isFirstOpenKey)
            }
        }
}
