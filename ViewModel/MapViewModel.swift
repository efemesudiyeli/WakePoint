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
    // Ankara
    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
   
    var destination: Destination? = nil
}


