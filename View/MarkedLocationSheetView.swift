//
//  MarkedLocationSheetView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 13.05.2025.
//

import MapKit
import SwiftUI

struct MarkedLocationSheetView: View {
    @State var isOnboarding = false
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss
    @Bindable var premiumManager: PremiumManager
    @State var showPremiumNeeded: Bool = false // TODO: Will change with paywall.
    @State var isSaved: Bool = false

    var locationTitle: String
    var distanceToUser: LocalizedStringKey
    var minutesToUser: LocalizedStringKey
    var address: Address?
    var coordinates: CLLocationCoordinate2D?
    @Binding var route: MKRoute?

    var body: some View {
        VStack(alignment: .leading) {
            Text(locationTitle)
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("Marked Location - ") + Text(distanceToUser) + Text(" away")

            Spacer()

            VStack(alignment: .leading) {
                Text("Details")
                    .font(.largeTitle)
                    .fontWeight(.heavy)

                Text("Address")
                    .fontWeight(.bold)
                Text(
                    [
                        address?.name,
                        address?.subLocality,
                        address?.locality,
                        address?.city,
                        address?.country,
                        address?.postalCode,
                    ]
                    .compactMap(\.self)
                    .joined(separator: ", ")
                )
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

                Divider()

                if let coordinates {
                    Text("Coordinates")
                        .fontWeight(.bold)
                    Text("\(coordinates.latitude), \(coordinates.longitude)")
                }
            }

            Spacer()
            HStack {
                Spacer()

                Button {
                    dismiss()
                    locationManager.destinationCoordinate = mapViewModel.destination?.coordinate
                    mapViewModel.isDestinationLocked = true
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation?.coordinate ?? .init()))
                    request.destination = MKMapItem(
                        placemark: MKPlacemark(coordinate: mapViewModel.destination?.coordinate ?? .init())
                    )
                    request.transportType = .automobile

                    let directions = MKDirections(request: request)
                    directions.calculate { response, _ in
                        if let route = response?.routes.first {
                            self.route = route
                        }
                    }

                    if let currentLocation = locationManager.currentLocation, let destination = mapViewModel.destination {
                        let startCoordinate = currentLocation.coordinate
                        let endCoordinate = destination.coordinate
                        
                        let latDifference = abs(startCoordinate.latitude - endCoordinate.latitude)
                        let lonDifference = abs(startCoordinate.longitude - endCoordinate.longitude)
                        
                        let centerLatitude = (startCoordinate.latitude + endCoordinate.latitude) / 2
                        let centerLongitude = (startCoordinate.longitude + endCoordinate.longitude) / 2
                        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
                        
                        let spanLatDelta = max(latDifference * 1.5, 0.01)
                        let spanLongDelta = max(lonDifference * 1.5, 0.01)
                        
                        mapViewModel.centerPositionToLocation(
                            position: centerCoordinate,
                            spanLatDelta: spanLatDelta,
                            spanLongDelta: spanLongDelta
                        )
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "play.fill")
                        Text(minutesToUser)
                            .bold()
                    }
                    .frame(width: 100, height: 70)
                    .foregroundStyle(.background)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }.disabled(isOnboarding)

                Button {
                    guard mapViewModel.canSaveNewDestinations else {
                        showPremiumNeeded = true
                        mapViewModel.notificationFeedbackGenerator
                            .notificationOccurred(.error)
                        return
                    }
                    if let coordinates {
                        mapViewModel
                            .saveDestinations(
                                destination: Destination(
                                    name: locationTitle,
                                    address: address,
                                    coordinate: coordinates
                                )
                            )
                        mapViewModel.notificationFeedbackGenerator
                            .notificationOccurred(.success)

                        withAnimation {
                            isSaved = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isSaved = false
                            }
                        }
                    }
                } label: {
                    VStack(spacing: 5) {
                        if isSaved {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "bookmark.fill")
                        }
                        Text(isSaved ? "Saved" : "Save")
                            .bold()
                    }
                    .frame(width: 100, height: 70)
                    .foregroundStyle(.background)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }.disabled(isOnboarding)

                Button {
                    dismiss()
                    mapViewModel.destination = nil
                    locationManager.destinationCoordinate = nil
                    route = nil
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "x.square.fill")
                        Text("Cancel")
                            .bold()
                    }
                    .frame(width: 100, height: 70)
                    .foregroundStyle(.background)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
                }.disabled(isOnboarding)
                Spacer()
            }
        }
        .presentationDetents([PresentationDetent.medium])
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.hidden)
        .padding()
        .onChange(of: $mapViewModel.savedDestinations.count) { _, newValue in
            if !premiumManager.isPremium, newValue >= 3 {
                mapViewModel.canSaveNewDestinations = false
            } else {
                mapViewModel.canSaveNewDestinations = true
            }
        }
        .onAppear {
            if !premiumManager.isPremium, mapViewModel.savedDestinations.count >= 3 {
                mapViewModel.canSaveNewDestinations = false
            } else {
                mapViewModel.canSaveNewDestinations = true
            }
        }
        .onDisappear {
            if !mapViewModel.isDestinationLocked {
                mapViewModel.destination = nil
                locationManager.destinationCoordinate = nil
                route = nil
            }
        }
        .alert(
            "Premium Needed",
            isPresented: $showPremiumNeeded
        ) {}
        message: {
            Text("You need to premium for do this.")
        }
    }
}
