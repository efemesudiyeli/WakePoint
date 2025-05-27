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
    @Binding var isMarkedLocationSheetPresented: Bool

    var body: some View {
        if !mapViewModel.searchResults.isEmpty {
            VStack {
                List(mapViewModel.searchResults, id: \.self) { item in
                    Button {
                        mapViewModel
                            .centerPositionToLocation(
                                position: item.placemark.coordinate,
                                offset: .topCenter
                            )
                        mapViewModel.destination = Destination(
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
                        print(mapViewModel.destination ?? "THERE IS NO DESTINATION SEARCH RESULTS VIEW")
                        mapViewModel.searchQuery = ""

                        if let currentLocation = locationManager.currentLocation {
                            mapViewModel
                                .calculateRoute(
                                    from: currentLocation.coordinate,
                                    to: item.placemark.coordinate
                                )
                        }

                        isSearchResultsPresented.toggle()
                        isMarkedLocationSheetPresented.toggle()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unknown")
                                .font(.headline)
                            Text(item.placemark.title ?? "")
                                .font(.subheadline)
                        }
                    }
                }
            }
        } else {
            Text("Location not found.")
        }
    }
}
