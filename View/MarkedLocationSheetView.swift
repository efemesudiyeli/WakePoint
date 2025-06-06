//
//  MarkedLocationSheetView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 13.05.2025.
//

import MapKit
import RevenueCatUI
import SwiftUI

struct MarkedLocationSheetView: View {
    @State var isOnboarding = false
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss
    @Bindable var premiumManager: PremiumManager
    @State var isPaywallPresented: Bool = false
    @State var isSaving: Bool = false
    @State private var hasAppeared = false
    @State var isSavedAlready: Bool = false

    var distanceToUser: LocalizedStringKey
    var minutesToUser: LocalizedStringKey
    var coordinates: CLLocationCoordinate2D?
    @Binding var route: MKRoute?

    var body: some View {
        VStack(alignment: .leading) {
            if mapViewModel.destination?.address == nil {
                ProgressView()
            } else {
                
                
                VStack(alignment: .leading) {
                    Text(mapViewModel.destination?.address?.name ?? "Address not found")
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
                        
                        if let destinationAddress = mapViewModel.destination?.address {
                            Text(
                                [
                                    destinationAddress.name,
                                    destinationAddress.subLocality,
                                    destinationAddress.locality,
                                    destinationAddress.city,
                                    destinationAddress.country,
                                    destinationAddress.postalCode,
                                ]
                                    .compactMap(\.self)
                                    .joined(separator: ", ")
                            )
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        
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
                            if let currentlocationCoordinate = locationManager.currentLocation?.coordinate, let destinationCoordinate = mapViewModel.destination?.coordinate {
                                mapViewModel
                                    .startNavigation(
                                        from: currentlocationCoordinate,
                                        to: destinationCoordinate
                                    )
                                locationManager
                                    .setVibratePoint(
                                        destinationCoordinate: destinationCoordinate
                                    )
                                
                                dismiss()
                                if let currentLocation = locationManager.currentLocation, let destination = mapViewModel.destination {
                                    let startCoordinate = currentLocation.coordinate
                                    let endCoordinate = destination.coordinate
                                    
                                    let middleCoordinateCalculation = mapViewModel
                                        .calculateMiddleCoordinate(
                                            startCoordinate: startCoordinate,
                                            endCoordinate: endCoordinate
                                        )
                                    
                                    mapViewModel.centerPositionToLocation(
                                        position: middleCoordinateCalculation.center,
                                        spanLatDelta: middleCoordinateCalculation.spanLat,
                                        spanLongDelta: middleCoordinateCalculation.spanLong
                                    )
                                }
                            }
                        } label: {
                            if mapViewModel.route != nil {
                                VStack(spacing: 5) {
                                    if mapViewModel.routeTransportType == .automobile {
                                        Image(systemName: "car.fill")
                                    } else {
                                        Image(systemName: "figure.walk")
                                    }
                                   
                                    
                                    Text(mapViewModel.route == nil ? "N/A" : minutesToUser)
                                        .bold()
                                }
                                .frame(width: 150, height: 70)
                                .foregroundStyle(.background)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color.green)
                                )
                            } else if mapViewModel.routeCantFound {
                                VStack(spacing: 5) {
                                    Image(systemName: "exclamationmark.magnifyingglass")
                                    
                                    Text("N/A")
                                        .bold()
                                }
                                .frame(width: 100, height: 70)
                                .foregroundStyle(.background)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                            } else {
                                VStack(spacing: 5) {
                                    ProgressView()
                                    
                                    Text("Loading")
                                        .bold()
                                }
                                .frame(width: 150, height: 70)
                                .foregroundStyle(.background)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            
                        }.disabled(isOnboarding || mapViewModel.route == nil)
                        
                        Button {
                            if !mapViewModel.canSaveNewDestinations {
                                isPaywallPresented = true
                                mapViewModel.notificationFeedbackGenerator
                                    .notificationOccurred(.error)
                                return
                            }
                            if let coordinates {
                                mapViewModel
                                    .saveDestinations(
                                        destination: Destination(
                                            address: mapViewModel.destination?.address,
                                            coordinate: coordinates
                                        )
                                    )
                                mapViewModel.notificationFeedbackGenerator
                                    .notificationOccurred(.success)
                                isSavedAlready = true
                                withAnimation {
                                    isSaving = true
                                }
                            }
                        } label: {
                            VStack(spacing: 5) {
                                if isSavedAlready {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Saved")
                                        .bold()
                                } else {
                                    if isSaving {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "bookmark.fill")
                                    }
                                    Text(isSaving ? "Saved" : "Save")
                                        .bold()
                                }
                            }
                            .frame(width: 150, height: 70)
                            .foregroundStyle(.background)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                            )
                        }.disabled(isOnboarding || isSavedAlready)
                        
//                        Button {
//                            dismiss()
//                            mapViewModel.destination = nil
//                            locationManager.destinationCoordinate = nil
//                            route = nil
//                            mapViewModel.isDestinationLocked = false
//                        } label: {
//                            VStack(spacing: 5) {
//                                Image(systemName: "xmark.circle.fill")
//                                Text("Remove")
//                                    .bold()
//                            }
//                            .frame(width: 150, height: 70)
//                            .foregroundStyle(.background)
//                            .background(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .fill(Color.red)
//                            )
//                        }.disabled(isOnboarding)
                        Spacer()
                    }
                }.overlay(alignment: .topTrailing) {
                    Button {
                        dismiss()
                        mapViewModel.destination = nil
                        locationManager.destinationCoordinate = nil
                        route = nil
                        mapViewModel.isDestinationLocked = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundStyle(.gray)
                            
            
                    }.frame(width: 25, height: 25)
                        .disabled(isOnboarding)
                }
            }
        }
        .padding()
        .interactiveDismissDisabled()
        .fullScreenCover(isPresented: $isPaywallPresented) {
            PaywallView().onDisappear {
                premiumManager.checkPremiumStatus()
            }
        }
        .onChange(of: $mapViewModel.savedDestinations.count) { _, newValue in
            if !premiumManager.isPremium, newValue >= 3 {
                mapViewModel.canSaveNewDestinations = false
            } else {
                mapViewModel.canSaveNewDestinations = true
            }
        }
        .onAppear {
            guard !hasAppeared else { return } // Temporary Solution
            hasAppeared = true

            isSavedAlready = mapViewModel.savedDestinations
                .contains(where: { element in
                    element == mapViewModel.destination
                })

            if !premiumManager.isPremium, mapViewModel.savedDestinations.count >= 3 {
                mapViewModel.canSaveNewDestinations = false
            } else {
                mapViewModel.canSaveNewDestinations = true
            }
        }
    }
}

#Preview {
    VStack {
        Text("Test")
    }.sheet(isPresented: .constant(true)) {
        MarkedLocationSheetView(
            isOnboarding: false,
            locationManager: LocationManager(),
            mapViewModel: MapViewModel(),
            premiumManager: PremiumManager(),
            isPaywallPresented: false,
            isSaving: false,
            distanceToUser: "123",
            minutesToUser: "123",
            coordinates: CLLocationCoordinate2D(),
            route: .constant(MKRoute())
        ).presentationDetents([.medium])
    }
}
