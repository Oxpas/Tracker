//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        TrackerCategoryStore(context: CoreDataStore.shared.viewContext)
    }()
    
    private lazy var trackerStore: TrackerStore = {
        TrackerStore(context: CoreDataStore.shared.viewContext, trackerCategoryStore: trackerCategoryStore)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        TrackerRecordStore(context: CoreDataStore.shared.viewContext)
    }()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            
            if UserDefaults.standard.object(forKey: "isFirstAppOpen") == nil {
                AppSettings.isFirstAppOpen = true
            }
            
            window?.rootViewController = makeRootViewController()
            window?.makeKeyAndVisible()

        }
        
        private func makeRootViewController() -> UIViewController {
            if AppSettings.isFirstAppOpen {
                let onboardingVC = OnboardingViewControllers()
                window?.rootViewController = onboardingVC
                return onboardingVC
            } else {
                return makeTabBarController()
            }
        }
        
        func showMainTabBar() {
            let tabBarController = makeTabBarController()
            
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.window?.rootViewController = tabBarController
            }, completion: nil)
        }
        
        private func makeTabBarController() -> UITabBarController {
            let tabBarController = TabBarController()
            
            tabBarController.trackerStore = trackerStore
            tabBarController.trackerRecordStore = trackerRecordStore
            
            tabBarController.loadViewIfNeeded()
            
            print("✅ TabBarController создан с зависимостями")
            print("📊 Передан trackerStore: \(trackerStore)")
            
            return tabBarController
        }
    

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

