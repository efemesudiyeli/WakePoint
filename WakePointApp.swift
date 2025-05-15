//
//  WakePointApp.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import SwiftUI

@main
struct WakePointApp: App {
    @State private var hasLaunchedBefore: Bool = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")

    var body: some Scene {
        WindowGroup {
            MapView(hasLaunchedBefore: $hasLaunchedBefore)
        }
    }
}
