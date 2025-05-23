//
//  SavedDestinationsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import RevenueCatUI
import SwiftUI

struct SavedDestinationsView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager
    @Bindable var premiumManager: PremiumManager
    @Binding var isSavedDestinationsViewPresented: Bool
    @Binding var isRouteConfirmationSheetPresented: Bool
    @State var isPaywallPresented: Bool = false

    var body: some View {
        if !mapViewModel.savedDestinations.isEmpty {
            VStack(alignment: .leading) {
                Text("Saved Destinations")
                    .font(.title)
                    .fontWeight(.black)
                Text("Swipe to destination options.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }.padding(.top)

            List {
                ForEach(mapViewModel.savedDestinations, id: \.id) { destination in
                    Button {
                        isSavedDestinationsViewPresented.toggle()
                        mapViewModel.destination = destination
                        if let currentLocation = locationManager.currentLocation {
                            mapViewModel
                                .calculateRoute(
                                    from: currentLocation.coordinate,
                                    to: destination.coordinate
                                ) { distance, minutes, _ in
                                    mapViewModel.destinationDistance = distance
                                    mapViewModel.destinationDistanceMinutes = minutes
                                }
                        }
                        isRouteConfirmationSheetPresented.toggle()
                        mapViewModel
                            .centerPositionToLocation(
                                position: destination.coordinate,
                                offset: .topCenter
                            )
                    } label: {
                        DestinationButtonView(destination: destination)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            mapViewModel.deleteDestination(destination: destination)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }

                if !premiumManager.isPremium, mapViewModel.savedDestinations.count >= 3 {
                    Button {
                        isPaywallPresented.toggle()
                    } label: {
                        Label("Buy Premium", systemImage: "star.circle")
                            .foregroundStyle(
                                Gradient(
                                    colors: [
                                        Color.indigo,
                                        Color.white,
                                    ]
                                )
                            )
                    }.listRowSeparator(.visible, edges: .top)
                        .listRowSeparatorTint(.primary)
                }
            }
            .presentationDetents([.medium])
            .presentationBackgroundInteraction(.enabled)
            .fullScreenCover(isPresented: $isPaywallPresented) {
                PaywallView()
            }

        } else {
            VStack {
                Text("😔")
                    .font(.largeTitle)
                Text("There is no saved destinations yet.")
            }.presentationDetents([PresentationDetent.medium])
                .presentationBackgroundInteraction(.enabled)
                .presentationBackgroundInteraction(.enabled)
        }
    }
}
