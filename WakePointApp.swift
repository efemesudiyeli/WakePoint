//
//  WakePointApp.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import GoogleMobileAds
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        MobileAds.shared.start(completionHandler: nil)

        return true
    }
}

@main
struct WakePointApp: App {
    @State private var hasLaunchedBefore: Bool = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(hasLaunchedBefore: $hasLaunchedBefore)
        }
    }
}
