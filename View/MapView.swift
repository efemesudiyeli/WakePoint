//
//  MapView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager

    var body: some View {
        Map(position: $mapViewModel.position, interactionModes: .all) {
            UserAnnotation()

            if let currentLocationCoordinate = locationManager.currentLocation?.coordinate {
                MapCircle(
                    center: currentLocationCoordinate,
                    radius: locationManager.circleDistance.rawValue
                ).foregroundStyle(mapViewModel.circleColor)
            }

            if let destination = mapViewModel.destination {
                Annotation(
                    mapViewModel.destination?.name ?? "Destination",
                    coordinate: destination.coordinate
                ) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
            }

            if let route = mapViewModel.route {
                MapPolyline(route.polyline)
                    .stroke(Color.blue, lineWidth: 5)
            }
        }
    }
}
