//
//  SearchView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import MapKit
import SwiftUI

struct SearchView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager
    @Binding var isSearchResultsPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            if !mapViewModel.autoCompleterResults.isEmpty, !mapViewModel.searchQuery.isEmpty {
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(
                            mapViewModel.autoCompleterResults,
                            id: \.self
                        ) { item in
                            Button {
                                mapViewModel.searchQuery = item.title

                                if let currentLocation = locationManager.currentLocation {
                                    mapViewModel.search(region: MKCoordinateRegion(
                                        center: currentLocation.coordinate,
                                        span: MKCoordinateSpan(
                                            latitudeDelta: 0.05,
                                            longitudeDelta: 0.05
                                        )
                                    ))
                                    isSearchResultsPresented = true
                                }
                            } label: {
                                Text(item.title)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(4)
                    .shadow(radius: 2)
                }
                .background(Color.oppositePrimary)
                .padding(.horizontal, 12)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
            }

            TextField(
                "Search for a place...",
                text: $mapViewModel.searchQuery
            )
            .submitLabel(.search)
            .textFieldStyle(
                CustomTextFieldStyle(searchQuery: $mapViewModel.searchQuery)
            )
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Dismiss") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .padding(.horizontal, 12)
            .onChange(of: mapViewModel.searchQuery) {
                _,
                    _ in
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 0.3) {
                        if let currentLocation = locationManager.currentLocation {
                            mapViewModel
                                .updateRelatedSearchResults(
                                    region: MKCoordinateRegion(
                                        center: currentLocation.coordinate,
                                        span: MKCoordinateSpan(
                                            latitudeDelta: 0.25,
                                            longitudeDelta: 0.25
                                        )
                                    )
                                )
                        }
                    }
            }
            .onSubmit {
                guard !mapViewModel.searchQuery.isEmpty else { return }
                if let currentLocation = locationManager.currentLocation {
                    mapViewModel.search(region: MKCoordinateRegion(
                        center: currentLocation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.05,
                            longitudeDelta: 0.05
                        )
                    ))
                    isSearchResultsPresented.toggle()
                }
            }
        }
    }
}
