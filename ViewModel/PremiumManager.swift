//
//  PremiumManager.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 15.05.2025.
//

import Foundation
import RevenueCat
import RevenueCatUI
import SwiftUI

@Observable
class PremiumManager {
    var isPremium: Bool = false
    let apiKey = Bundle.main.infoDictionary?["REVENUECAT_API_KEY"] as? String ?? ""

    init(isPremium _: Bool = false) {
        setup()
    }

    func setup() {
        Purchases.configure(withAPIKey: apiKey)
        checkPremiumStatus()
    }
    
    func tryRestorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let info = customerInfo {
                DispatchQueue.main.async {
                    self.isPremium = info.entitlements["Premium"]?.isActive == true
                    completion(self.isPremium)
                }
            } else if let error = error {
                print("Restore failed: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    func checkPremiumStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let info = customerInfo {
                DispatchQueue.main.async {
                    self.isPremium = info.entitlements["Premium"]?.isActive == true
                }
            } else {
                print("Failed to get customer info: \(String(describing: error))")
            }
        }
    }
}
