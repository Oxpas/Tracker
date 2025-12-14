//
//  TrackerSnapshotsTests.swift
//  TrackerSnapshotsTests
//
//  Created by Николай Замараев on 11.12.2025.
//

@testable import Tracker
import XCTest
import SnapshotTesting

final class TrackerSnapshotsTests: XCTestCase {
    
    func testViewControllerForLightTheme() {
        let viewController = TrackerViewController()
        
        viewController.loadViewIfNeeded()
        
        assertSnapshot(
            of: viewController,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "light_mode",
            record: false
        )
    }
    
    func testViewControllerForDarkTheme() {
        let viewController = TrackerViewController()
        
        viewController.loadViewIfNeeded()
        
        assertSnapshot(
            of: viewController,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark_mode",
            record: false
        )
    }
    
}
