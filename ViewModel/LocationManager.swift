//
//  LocationManager.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import AudioToolbox
import CoreLocation
import SwiftUICore
import UIKit
import UserNotifications

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var destinationCoordinate: CLLocationCoordinate2D?
    private var hasVibrated = false
    var circleDistance: CircleDistance = .long
    var vibrateSeconds: VibrateSeconds = .long
    var isUserReachedDistance = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        requestNotificationPermission()
    }

    func vibratePhone(seconds: Int) {
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

    func saveSettings() {
        UserDefaults.standard
            .set(circleDistance.rawValue, forKey: "CircleDistance")
        UserDefaults.standard
            .set(vibrateSeconds.rawValue, forKey: "VibrateSeconds")
    }

    func fetchSettings() {
        if let rawDistance = UserDefaults.standard.value(forKey: "CircleDistance") as? Double,
           let distance = CircleDistance(rawValue: rawDistance)
        {
            circleDistance = distance
        }

        if let rawSeconds = UserDefaults.standard.value(forKey: "VibrateSeconds") as? Int,
           let seconds = VibrateSeconds(rawValue: rawSeconds)
        {
            vibrateSeconds = seconds
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        if let destination = destinationCoordinate {
            let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
            let distance = location.distance(from: destinationLocation)

            isUserReachedDistance = distance <= circleDistance.rawValue
            if isUserReachedDistance, !hasVibrated {
                hasVibrated = true
                vibratePhone(seconds: vibrateSeconds.rawValue)
                let content = UNMutableNotificationContent()
                content.title = "Hedefe Yaklaştın!"
                content.body = "Belirlediğin konuma ulaştın veya çok yakınsın."
                content.sound = .default

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Bildirim izni hatası: \(error)")
            } else {
                print("Bildirim izni verildi: \(granted)")
            }
        }
    }

    func resetDestination() {
        isUserReachedDistance = false
        destinationCoordinate = nil
    }
}

enum CircleDistance: Double, CaseIterable {
    case short = 250
    case medium = 500
    case long = 750
    case veryLong = 1000
    case extreme = 1500
}

enum VibrateSeconds: Int, CaseIterable {
    case short = 5
    case medium = 10
    case long = 15
}
