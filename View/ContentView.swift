//
//  ContentView.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 4.05.2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    
    var body: some View {
        MapReader { reader in
            Map(position: $mapViewModel.position, interactionModes: .all){
                UserAnnotation()
                
                if let destination = mapViewModel.destination {
                    Marker("Destination", coordinate: destination.coordinate)
                }
            }
            .onTapGesture { screenCoord in
                if let tappedCoord = reader.convert(screenCoord, from: .local) {
                  
                    mapViewModel.destination = Destination(
                        coordinate: tappedCoord
                    )
                    locationManager.destinationCoordinate = tappedCoord
                }
            }
           
        }
    }
}

#Preview {
    ContentView()
}
