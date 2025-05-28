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
    @Environment(\.dismiss) var dismiss
    @Binding var isMarkedLocationSheetViewPresented: Bool
    @State var isPaywallPresented: Bool = false

    var body: some View {
        VStack {
            if !mapViewModel.savedDestinations.isEmpty {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Saved Destinations")
                            .font(.title)
                            .fontWeight(.black)
                        Text("Swipe to destination options.")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top)

                    List {
                        ForEach(mapViewModel.savedDestinations, id: \.id) { destination in
                            Button {
                                dismiss()
                                mapViewModel.destination = destination
                                if let currentLocation = locationManager.currentLocation {
                                    mapViewModel
                                        .calculateRoute(
                                            from: currentLocation.coordinate,
                                            to: destination.coordinate
                                        )
                                }
                                isMarkedLocationSheetViewPresented.toggle()
                                mapViewModel
                                    .centerPositionToLocation(
                                        position: destination.coordinate,
                                        offset: .topCenter,
                                        spanLatDelta: 0.05,
                                        spanLongDelta: 0.05
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
                }

                .fullScreenCover(isPresented: $isPaywallPresented) {
                    PaywallView().onDisappear {
                        premiumManager.checkPremiumStatus()
                    }
                }

            } else {
                VStack {
                    Text("😔")
                        .font(.largeTitle)
                    Text("There is no saved destinations yet.")
                }
            }
        }.presentationDetents([PresentationDetent.medium])
            .presentationBackgroundInteraction(.disabled)
            .presentationDragIndicator(.hidden)
    }
}
