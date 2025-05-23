//
//  WakePointApp.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import SwiftUI
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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
