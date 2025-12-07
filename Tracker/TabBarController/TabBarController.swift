//
//  ViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//
import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let firstVC = TrackerViewController()
        
        // 2. Настраиваем его с данными
        configureTrackerViewController(firstVC)
        
        firstVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: UIImage(systemName: "record.circle.fill")
        )
        
        // 3. Создаем второй экран
        let secondVC = StatisticViewController()
        secondVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )
        
        // 4. Устанавливаем контроллеры
        let trackersNavigationController = UINavigationController(rootViewController: firstVC)
        let statisticsNavigationController = UINavigationController(rootViewController: secondVC)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
        
        print("✅ Контроллеры настроены")
        print("📊 TrackerViewController trackerStore: \(String(describing: firstVC.trackerStore))")
    }
    
    private func setupTabBarAppearance() {
        // Настройка внешнего вида TabBar
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = false
        
        tabBar.layer.borderWidth = 1.0 / UIScreen.main.scale
        tabBar.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor
        tabBar.clipsToBounds = true
    }
    
    
    private func configureTrackerViewController(_ vc: TrackerViewController) {
        // Используем общий сервис
        let dataService = DataService.shared
        
        vc.trackerStore = dataService.trackerStore
        vc.trackerRecordStore = dataService.trackerRecordStore
        
        // Устанавливаем делегата
        dataService.trackerStore.delegate = vc
        
        print("✅ TrackerViewController настроен")
        print("📊 TrackerStore делегат: \(String(describing: dataService.trackerStore.delegate))")
    }
}

