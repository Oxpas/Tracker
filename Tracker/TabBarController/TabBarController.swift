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
        // Создаем первый экран
        let firstVC = TrackerViewController()
        firstVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: UIImage(systemName: "record.circle.fill")
        )
        
        // Создаем второй экран
        let secondVC = StatisticViewController()
        secondVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )
        
        // Устанавливаем контроллеры в tab bar
        let trackersNavigationController = UINavigationController(rootViewController: firstVC)
        let statisticsNavigationController = UINavigationController(rootViewController: secondVC)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
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
}

