//
//  TabBarController.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    var trackerStore: TrackerStore?
    var trackerRecordStore: TrackerRecordStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let firstVC = TrackerViewController()
        
        if let trackerStore = trackerStore,
           let trackerRecordStore = trackerRecordStore {
            firstVC.trackerStore = trackerStore
            firstVC.trackerRecordStore = trackerRecordStore
            trackerStore.delegate = firstVC
        }
        
        firstVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_tab", comment: "TabBarController"),
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: UIImage(systemName: "record.circle.fill")
        )
        
        let secondVC = StatisticViewController()
        secondVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_tab", comment: "TabBarController"),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )
        
        let trackersNavigationController = UINavigationController(rootViewController: firstVC)
        let statisticsNavigationController = UINavigationController(rootViewController: secondVC)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]

    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = UIColor.systemBackground
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = false
        
        tabBar.layer.borderWidth = 1.0 / UIScreen.main.scale
        tabBar.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor
        tabBar.clipsToBounds = true
    }
}
