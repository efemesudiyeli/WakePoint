//
//  SearchResultsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//

import SwiftUI

struct SearchResultsView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager
    @Binding var isSearchResultsPresented: Bool
    @Binding var isRouteConfirmationSheetPresented: Bool

    var body: some View {
        if !mapViewModel.searchResults.isEmpty {
            List(mapViewModel.searchResults, id: \.self) { item in
                Button {
                    mapViewModel
                        .centerPositionToLocation(
                            position: item.placemark.coordinate,
                            offset: .topCenter
                        )
                    mapViewModel.destination = Destination(
                        name: item.placemark.name,
                        address: Address(
                            name: item.placemark.name,
                            locality: item.placemark.locality,
                            country: item.placemark.country,
                            city: item.placemark.administrativeArea,
                            postalCode: item.placemark.postalCode,
                            subLocality: item.placemark.subLocality
                        ),
                        coordinate: item.placemark.coordinate
                    )
                    mapViewModel.searchQuery = ""

                    if let currentLocation = locationManager.currentLocation {
                        mapViewModel
                            .calculateRoute(
                                from: currentLocation.coordinate,
                                to: item.placemark.coordinate
                            ) { distance, minutes, _ in
                                mapViewModel.destinationDistance = distance
                                mapViewModel.destinationDistanceMinutes = minutes
                            }
                    }

                    isSearchResultsPresented.toggle()
                    isRouteConfirmationSheetPresented.toggle()
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown")
                            .font(.headline)
                        Text(item.placemark.title ?? "")
                            .font(.subheadline)
                    }
                }
            }
            .presentationDetents([PresentationDetent.medium])
            .presentationBackgroundInteraction(.enabled)
            .presentationBackgroundInteraction(.enabled)

        } else {
            Text("Location not found.")
                .presentationDetents([PresentationDetent.medium])
                .presentationBackgroundInteraction(.enabled)
        }
    }
}
