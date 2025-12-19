//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Николай Замараев on 11.12.2025.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "e1784d7f-1788-49ea-8d19-4b9903832cf0") else { return }
        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params: [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", "\(error)")
        })
    }
    
    
}
