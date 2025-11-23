//
//  SceneDelegate.swift
//  YourQuickToDo
//
//  Created by User on 14/09/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


  
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        print("🚀 SceneDelegate: scene willConnectTo session")

        guard let windowScene = (scene as? UIWindowScene) else { 
            print("❌ SceneDelegate: Failed to cast scene to UIWindowScene")
            return 
        }

        // Create window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        print("✅ SceneDelegate: Window created")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let isOnboardingCompleted = UserDefaults.standard.isOnboardingCompleted
        print("👤 SceneDelegate: isOnboardingCompleted = \(isOnboardingCompleted)")

        // If onboarding completed → go to TabBar
        if isOnboardingCompleted {
            guard let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController else {
                fatalError("❌ MainTabBarController not found")
            }
            tabBarVC.selectedIndex = 0 
            window.rootViewController = tabBarVC
            print("✅ SceneDelegate: Set rootViewController to MainTabBarController")
        }
        // Onboarding NOT completed → show Onboarding
        else {
            guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnloardingVC") as? OnloardingVC else {
                fatalError("❌ OnloardingVC not found")
            }
            window.rootViewController = onboardingVC
            print("✅ SceneDelegate: Set rootViewController to OnloardingVC")
        }

        window.makeKeyAndVisible()
        print("✅ SceneDelegate: window.makeKeyAndVisible() called. Window frame: \(window.frame)")
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}
