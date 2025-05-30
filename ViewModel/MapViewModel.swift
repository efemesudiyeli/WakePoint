//
//  ViewModel.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//
import Foundation
import MapKit
import SwiftUI
import UIKit

@Observable
class MapViewModel: NSObject, MKLocalSearchCompleterDelegate {
    enum OffsetPosition {
        case center
        case topCenter
        case bottomCenter
    }

    var mapStyle: MapStyle = .standard
    var circleColor: Color = .blue.opacity(0.5)
    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))

    var canSaveNewDestinations: Bool = true
    var destination: Destination?
    var destinationDistanceMinutes: LocalizedStringKey?
    var destinationDistance: LocalizedStringKey?
    var isDestinationLocked: Bool = false
    var savedDestinations: [Destination] = []
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator = .init()
    var searchQuery = ""
    var searchResults: [MKMapItem] = []
    var route: MKRoute?
    var isNavigationStarted: Bool = false
    var routeTransportType: MKDirectionsTransportType = .automobile
    var routeCantFound: Bool = false
    var autoCompleterResults: [MKLocalSearchCompletion] = []
    private var completer: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        return completer
    }()

    var isDeveloperMode: Bool {
        (Bundle.main.infoDictionary?["DEVELOPER_MODE"] as? String)?.lowercased() == "true"
    }

    func centerPositionToLocation(
        position: CLLocationCoordinate2D,
        offset: OffsetPosition = .center,
        spanLatDelta: CLLocationDegrees = 0.01,
        spanLongDelta: CLLocationDegrees = 0.01
    ) {
        withAnimation {
            var region = MKCoordinateRegion(
                center: position,
                span: MKCoordinateSpan(
                    latitudeDelta: spanLatDelta,
                    longitudeDelta: spanLongDelta
                )
            )

            guard offset != .center else {
                self.position = MapCameraPosition.region(region)
                return
            }

            let offsetHeight: CGFloat = switch offset {
            case .topCenter:
                UIScreen.main.bounds.height * 0.25
            case .bottomCenter:
                -UIScreen.main.bounds.height * 0.25
            default:
                0
            }

            let latitudeOffset = offsetHeight * region.span.latitudeDelta / UIScreen.main.bounds.height

            let adjustedCoordinate = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: position.latitude - latitudeOffset,
                    longitude: position.longitude
                ),
                span: region.span
            ).center

            region.center = adjustedCoordinate
            self.position = MapCameraPosition.region(region)
        }
    }

    func updateRelatedSearchResults(region: MKCoordinateRegion) {
        completer.delegate = self
        completer.queryFragment = searchQuery
        completer.region = region
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.autoCompleterResults = completer.results
        }
    }

    func search(region: MKCoordinateRegion) {
        searchResults = []
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.searchResults = items
            }
        }
    }

    func fetchSettings() {
        if let colorString: String = UserDefaults.standard.value(forKey: "CircleColor") as? String {
            if let color = Color(hex: colorString) {
                circleColor = color
            }
        }
    }

    func fetchAddress(
        for coordinates: CLLocationCoordinate2D,
        completion: @escaping (Address?) -> Void
    ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        geocoder.reverseGeocodeLocation(location) {
            placemarks,
                _ in
            if let placemark = placemarks?.first {
                let address = Address(
                    name: placemark.name,
                    locality: placemark.locality,
                    country: placemark.country,
                    city: placemark.administrativeArea,
                    postalCode: placemark.postalCode,
                    subLocality: placemark.subLocality
                )
                completion(
                    address)
                self.destination?.address = address
            } else {
                print("Can't find address")
                completion(nil)
            }
        }
    }

    func startNavigation(
        from _: CLLocationCoordinate2D,
        to _: CLLocationCoordinate2D
    ) {
        isNavigationStarted = true
        isDestinationLocked = true
//        calculateRoute(from: from, to: to)

        print("Starting Navigation \(route?.debugDescription ?? "")")
    }

    func stopNavigation() {
        isNavigationStarted = false
        isDestinationLocked = false
        destination = nil
        route = nil
    }

    func calculateMiddleCoordinate(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) -> (
        center: CLLocationCoordinate2D, spanLat: Double, spanLong: Double
    ) {
        let latDifference = abs(startCoordinate.latitude - endCoordinate.latitude)
        let lonDifference = abs(startCoordinate.longitude - endCoordinate.longitude)

        let centerLatitude = (startCoordinate.latitude + endCoordinate.latitude) / 2
        let centerLongitude = (startCoordinate.longitude + endCoordinate.longitude) / 2
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        let spanLatDelta = max(latDifference * 1.5, 0.01)
        let spanLongDelta = max(lonDifference * 1.5, 0.01)

        return (centerCoordinate, spanLatDelta, spanLongDelta)
    }

    func calculateRoute(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) {
        routeCantFound = false
        route = nil
        let startPlacemark = MKPlacemark(coordinate: start)
        let endPlacemark = MKPlacemark(coordinate: end)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = routeTransportType

        let directions = MKDirections(request: request)
        directions.calculate {
            response,
                error in
            if let error {
                print("Error calculating route: \(error.localizedDescription)")
                self.routeCantFound = true
                return
            }

            if let route = response?.routes.first {
                self.route = route
                let distance = LocalizedStringKey(String(
                    format: "%.1f km",
                    route.distance / 1000
                ))
                let travelTime = route.expectedTravelTime
                let minutesInt = Int(travelTime / 60)
                let hours = minutesInt / 60
                let days = hours / 24
                let remainingHours = hours % 24
                let remainingMinutes = minutesInt % 60

                let minutes: LocalizedStringKey = if days > 0 {
                    "\(days)d \(remainingHours)h"
                } else if hours > 0 {
                    "\(hours)h \(remainingMinutes)m"
                } else {
                    "\(minutesInt)m"
                }
                self.destinationDistanceMinutes = minutes
                self.destinationDistance = distance
                print("Route calculated")
            } else {
                print("No route found")
                self.routeCantFound = true
            }
        }
    }

    func saveDestinations(destination: Destination) {
        savedDestinations.append(destination)

        do {
            let data = try JSONEncoder().encode(savedDestinations)
            UserDefaults.standard.set(data, forKey: "SavedDestinations")
        } catch {
            print("Failed to save destinations: \(error.localizedDescription)")
        }
    }

    func loadDestinations() {
        guard let data = UserDefaults.standard.data(forKey: "SavedDestinations") else { return }
        do {
            savedDestinations = try JSONDecoder()
                .decode([Destination].self, from: data)
        } catch {
            print("Failed to load destinations: \(error.localizedDescription)")
        }
    }

    func deleteDestination(destination: Destination) {
        if let index = savedDestinations.firstIndex(where: { $0.id == destination.id }) {
            savedDestinations.remove(at: index)

            do {
                let data = try JSONEncoder().encode(savedDestinations)
                UserDefaults.standard.set(data, forKey: "SavedDestinations")
            } catch {
                print("Failed to save destinations after deletion: \(error.localizedDescription)")
            }
        }
    }

    func renameDestination(destination: Destination, newName: String) {
        Task { @MainActor in
            if let index = savedDestinations.firstIndex(where: { $0.id == destination.id }) {
                var updatedDestination = destination
                if updatedDestination.address == nil {
                    updatedDestination.address = Address(name: newName)
                } else {
                    updatedDestination.address?.name = newName
                }
                
                do {
                    savedDestinations[index] = updatedDestination
                    let data = try JSONEncoder().encode(savedDestinations)
                    UserDefaults.standard.set(data, forKey: "SavedDestinations")
                } catch {
                    print("Failed to save destinations after renaming: \(error.localizedDescription)")
                }
            }
        }
    }
}
