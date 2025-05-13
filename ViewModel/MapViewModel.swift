//
//  ViewModel.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//
import Foundation
import MapKit
import SwiftUI

@Observable
class MapViewModel {
    var circleColor: Color = .blue.opacity(0.5)
    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    
    var destination: Destination? = nil
    var clickedLocationOnSearch: MKPlacemark? = nil
    var destinationAddress: Address? = nil
    var destinationDistanceMinutes: String? = nil
    var destinationDistance: String? = nil
    var isDestinationLocked: Bool = false
    
    func centerPositionToLocation(position: CLLocationCoordinate2D) -> Void {
        withAnimation {
            self.position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: position,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        }
    }
    
    var searchQuery = ""
    var searchResults: [MKMapItem] = []
    
    func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.searchResults = items
            }
        }
    }
    
    func resetDestination() -> Void {
        destination = nil
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
 error in
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
                completion(nil)
            }
        }
    }
    
    func calculateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, completion: @escaping (String?, String?) -> Void) {
        print("Start Coordinate: \(start)")
        print("End Coordinate: \(end)")
        
        let startPlacemark = MKPlacemark(coordinate: start)
        let endPlacemark = MKPlacemark(coordinate: end)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating route: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let route = response?.routes.first else {
                print("No route found")
                completion(nil, nil)
                return
            }
            
            let distance = String(format: "%.1f km", route.distance / 1000)
            let minutes = "\(Int(route.expectedTravelTime / 60)) min"
            print("Distance: \(distance), Minutes: \(minutes)")
            completion(distance, minutes)
        }
    }
   
  
}
