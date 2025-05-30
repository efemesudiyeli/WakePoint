//
//  LocationManager.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import AudioToolbox
import CoreLocation
import UIKit
import UserNotifications
import SwiftUI

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    enum AlertType: String {
        case vibration
        case sound
    }

    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var destinationCoordinate: CLLocationCoordinate2D?
    private var hasVibrated = false
    var circleDistance: CircleDistance = .long
    var vibrateSeconds: VibrateSeconds = .medium
    var isUserReachedDistance = false
    var alertType: AlertType = .vibration
    var isLocationAuthorized: Bool = false
    var isNavigationActive: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        requestNotificationPermission()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAuthorized = true
        default:
            isLocationAuthorized = false
        }
    }

    func stopBackgroundUpdatingLocation() {
        locationManager.allowsBackgroundLocationUpdates = false
        print("Stopping background updating location")
    }

    func startBackgroundUpdatingLocation() {
        locationManager.allowsBackgroundLocationUpdates = true
        print("Starting background updating location")
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if isNavigationActive {
                locationManager.allowsBackgroundLocationUpdates = true
            }
        case .background:
            if !isNavigationActive {
                locationManager.allowsBackgroundLocationUpdates = false
            }
        case .inactive:
            break
        @unknown default:
            break
        }
    }

    func setNavigationActive(_ active: Bool) {
        isNavigationActive = active
        locationManager.allowsBackgroundLocationUpdates = active
    }

    func playAlert(seconds: Int) {
        var elapsed = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)

            elapsed += 1
            if elapsed >= seconds {
                timer.invalidate()
                self.hasVibrated = false
            }
        }
    }

    func playAlarmSound(seconds: Int) {
        var elapsed = 0
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            AudioServicesPlaySystemSound(SystemSoundID(1005)) // Or choose any other system sound ID

            elapsed += 1
            if elapsed >= seconds {
                timer.invalidate()
                self.hasVibrated = false
            }
        }
    }

    func setVibratePoint(destinationCoordinate: CLLocationCoordinate2D) {
        self.destinationCoordinate = destinationCoordinate
    }

    func saveSettings() {
        UserDefaults.standard
            .set(circleDistance.rawValue, forKey: "CircleDistance")
        UserDefaults.standard
            .set(vibrateSeconds.rawValue, forKey: "VibrateSeconds")
        UserDefaults.standard.set(alertType.rawValue, forKey: "AlertType")
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

        if let rawAlert = UserDefaults.standard.string(forKey: "AlertType"),
           let savedAlertType = AlertType(rawValue: rawAlert)
        {
            alertType = savedAlertType
        }
    }

    fileprivate func sendWakeUpNotification() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time to wake up!")
        content.body = String(localized: "You have reached or are very close to the position you set.")
        content.sound = .defaultCritical

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
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
                switch alertType {
                case .vibration:
                    playAlert(seconds: vibrateSeconds.rawValue)
                case .sound:
                    playAlarmSound(seconds: vibrateSeconds.rawValue)
                }
                sendWakeUpNotification()
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
        stopBackgroundUpdatingLocation()
    }
}
