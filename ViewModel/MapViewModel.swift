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
class MapViewModel {
    enum OffsetPosition {
        case center
        case topCenter
        case bottomCenter
    }

    var circleColor: Color = .blue.opacity(0.5)
    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))

    var canSaveNewDestinations: Bool = true
    var destination: Destination?
    var destinationAddress: Address?
    var destinationDistanceMinutes: LocalizedStringKey?
    var destinationDistance: LocalizedStringKey?
    var isDestinationLocked: Bool = false
    var savedDestinations: [Destination] = []
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator = .init()
    var searchQuery = ""
    var searchResults: [MKMapItem] = []
    var relatedSearchResults: [MKMapItem] = []
    var route: MKRoute?
    var promotionCodeInput: String = ""

    // MARK: Change here when release

    var isDeveloperMode: Bool = false

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

    func updateRelatedSearchResults(query: String) {
        relatedSearchResults = []
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.relatedSearchResults = items
            }
        }
    }

    func search() {
        searchResults = []
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.searchResults = items
            }
        }
    }

    func resetDestination() {
        destination = nil
        isDestinationLocked = false
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
                completion(
                    Address(
                        name: placemark.name,
                        locality: placemark.locality,
                        country: placemark.country,
                        city: placemark.administrativeArea,
                        postalCode: placemark.postalCode,
                        subLocality: placemark.subLocality

                    ))
            } else {
                print("Can't find address")
                completion(nil)
            }
        }
    }

    func calculateRoute(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        completion: @escaping (
            LocalizedStringKey?,
            LocalizedStringKey?,
            MKRoute?
        ) -> Void
    ) {
        print("Start Coordinate: \(start)")
        print("End Coordinate: \(end)")

        let startPlacemark = MKPlacemark(coordinate: start)
        let endPlacemark = MKPlacemark(coordinate: end)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate {
            response,
                error in
            if let error {
                print("Error calculating route: \(error.localizedDescription)")
                completion(nil, nil, nil)
                return
            }

            guard let route = response?.routes.first else {
                print("No route found")
                completion(nil, nil, nil)
                return
            }

            let distance = LocalizedStringKey(String(
                format: "%.1f km",
                route.distance / 1000
            ))
            let minutes: LocalizedStringKey = "\(Int(route.expectedTravelTime / 60)) min"
            print("Distance: \(distance), Minutes: \(minutes)")
            completion(distance, minutes, route)
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

    func renameDestination(destination: Destination, name: String) {
        if let index = savedDestinations.firstIndex(where: { $0.id == destination.id }) {
            savedDestinations[index].name = name

            do {
                let data = try JSONEncoder().encode(savedDestinations)
                UserDefaults.standard.set(data, forKey: "SavedDestinations")
            } catch {
                print("Failed to save destinations after renaming: \(error.localizedDescription)")
            }
        }
    }
}
