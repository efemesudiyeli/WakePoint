//
//  LocationManager.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import CoreLocation
import UIKit
import SwiftUICore
import AudioToolbox

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var destinationCoordinate: CLLocationCoordinate2D?
    private var hasVibrated = false
    private var vibrateDistance: Double = 1000

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    fileprivate func vibratePhone(seconds: Int) {
        var elapsed = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactGenerator.impactOccurred()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            elapsed += 1
            if elapsed >= seconds {
                timer.invalidate()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        if let destination = destinationCoordinate {
            let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
            let distance = location.distance(from: destinationLocation)

            if distance <= vibrateDistance && !hasVibrated {
                hasVibrated = true

                vibratePhone(seconds: 5)
            }
        }
    }
}
