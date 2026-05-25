//
//  SceneDelegate.swift
//  Everec 2.0
//
//  Created by Sudarshan Sudhakar on 03/07/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let rootVC: UIViewController
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            rootVC = MoodSelectionViewController()
        } else {
            rootVC = OnboardingViewController()
        }

        let navController = UINavigationController(rootViewController: rootVC)
        navController.navigationBar.prefersLargeTitles = false

        window.rootViewController = navController
        window.overrideUserInterfaceStyle = .dark
        self.window = window
        window.makeKeyAndVisible()
    }
}

