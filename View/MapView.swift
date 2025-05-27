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
    @Bindable var premiumManager: PremiumManager
    @State private var isMarkedLocationSheetViewPresented = false
    @State private var isMarkerSelected = false
    @State private var circleOpacity: Double = 0
    @State var isMarkerDeleted: Bool = false

    var body: some View {
        MapReader { reader in
            Map(
                position: $mapViewModel.position,
                interactionModes: .all
            ) {
                UserAnnotation()

                if let currentLocationCoordinate = locationManager.currentLocation?.coordinate {
                    MapCircle(
                        center: currentLocationCoordinate,
                        radius: locationManager.circleDistance.rawValue
                    ).foregroundStyle(mapViewModel.circleColor)
                }

                if let destination = mapViewModel.destination {
                    Annotation(
                        mapViewModel.destination?.address?.name ?? "Destination",
                        coordinate: destination.coordinate
                    ) {
                        ZStack(alignment: .center) {
                            if isMarkerSelected {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 44, height: 44)
                                    .shadow(radius: 2)
                                    .opacity(circleOpacity)
                            }

                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }

                        .contentShape(
                            Rectangle()
                        )
                    }
                }

                if mapViewModel.isNavigationStarted {
                    if let route = mapViewModel.route {
                        MapPolyline(route.polyline)
                            .stroke(Color.blue, lineWidth: 5)
                    }
                }
            }
            .mapControlVisibility(.automatic)
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapScaleView()
                MapPitchToggle()
            }
            .mapStyle(mapViewModel.mapStyle)
            

            .onTapGesture { screenCord in
                guard mapViewModel.destination == nil else {
                    if !mapViewModel.isNavigationStarted {
                        mapViewModel.destination = nil
                        isMarkerDeleted = true
                    }
                    return
                }

                if let tappedCoord = reader.convert(screenCord, from: .local) {
                    if mapViewModel.isDestinationLocked { return }
                    mapViewModel.destination = Destination(
                        coordinate: tappedCoord
                    )

                    mapViewModel.fetchAddress(for: tappedCoord) { address in
                        mapViewModel.destination?.address = address
                    }

                    if let userCoordinate = locationManager.currentLocation?.coordinate {
                        mapViewModel.calculateRoute(from: userCoordinate, to: tappedCoord)
                    }
                    isMarkedLocationSheetViewPresented = true
                    isMarkerDeleted = false

                    mapViewModel
                        .centerPositionToLocation(
                            position: tappedCoord,
                            offset: .topCenter,
                            spanLatDelta: 0.05,
                            spanLongDelta: 0.05
                        )
                }
            }
            .sheet(isPresented: $isMarkedLocationSheetViewPresented) {
                MarkedLocationSheetView(
                    locationManager: locationManager,
                    mapViewModel: mapViewModel,
                    premiumManager: premiumManager,
                    distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                    minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                    coordinates: mapViewModel.destination?.coordinate,
                    route: $mapViewModel.route
                )
                .presentationDetents([.medium])
            }
            .onChange(of: isMarkedLocationSheetViewPresented) { _, isPresented in
                if !isPresented {
                    withAnimation(.easeOut(duration: 0.5)) {
                        circleOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isMarkerSelected = false
                    }
                }
            }
        }
        .sensoryFeedback(.impact, trigger: isMarkerDeleted) { oldValue, newValue in
            oldValue == false && newValue == true
        }
        .sensoryFeedback(.selection, trigger: isMarkerSelected)
    }
}
