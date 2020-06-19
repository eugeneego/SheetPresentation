//
// AppDelegate
// SimpleSheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.tintColor = .systemOrange
        self.window = window

        let controller = MainViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return true
    }
}
