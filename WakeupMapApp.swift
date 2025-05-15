//
//  WakeupMapApp.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import SwiftUI

@main
struct WakeupMapApp: App {
    @State private var hasLaunchedBefore: Bool = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")

    var body: some Scene {
        WindowGroup {
            MapView(hasLaunchedBefore: $hasLaunchedBefore)
        }
    }
}
