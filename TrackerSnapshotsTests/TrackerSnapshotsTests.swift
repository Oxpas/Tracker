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
    
    func testViewController() {
        let viewController = TrackerViewController()
        
        viewController.loadViewIfNeeded()
        
        assertSnapshot(
            of: viewController,
            as: .image,
            named: "light_mode",
            record: false
        )
    }
    
}
