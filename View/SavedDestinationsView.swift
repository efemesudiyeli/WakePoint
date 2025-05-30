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
    @State private var destinationToRename: Destination?
    @State private var newName: String = ""
    @State private var isRenaming: Bool = false

    var body: some View {
        VStack {
            if !mapViewModel.savedDestinations.isEmpty {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Saved Destinations")
                            .font(.title)
                            .fontWeight(.black)
                        Text("Swipe to destination options.")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    .padding()

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
                                
                                Button {
                                    destinationToRename = destination
                                    newName = destination.address?.name ?? ""
                                    isRenaming = true
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                .tint(.blue)
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
                            }
                            .listRowSeparator(.visible, edges: .top)
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
                    Spacer()
                    Text("😔")
                        .font(.largeTitle)
                    Text("There is no saved destinations yet.")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $isRenaming) {
            NavigationView {
                Form {
                    Section {
                        TextField("New name", text: $newName)
                    }
                }
                .navigationTitle("Rename Destination")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            withAnimation {
                                isRenaming = false
                                destinationToRename = nil
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Rename") {
                            if let destination = destinationToRename, !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                withAnimation {
                                    mapViewModel.renameDestination(destination: destination, newName: newName)
                                    isRenaming = false
                                    destinationToRename = nil
                                }
                            }
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.height(200)])
            .presentationBackgroundInteraction(.disabled)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundStyle(.gray)
            }
            .frame(width: 25, height: 25)
            .padding()
        }
        .interactiveDismissDisabled()
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
        .presentationBackgroundInteraction(.disabled)
    }
}

#Preview {
    SavedDestinationsView(
        mapViewModel: MapViewModel(),
        locationManager: LocationManager(),
        premiumManager: PremiumManager(),
        isMarkedLocationSheetViewPresented: .constant(true)
    )
}
