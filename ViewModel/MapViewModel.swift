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
    
   
  
}


