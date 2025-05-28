//
//  OnboardingView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 15.05.2025.
//

import CoreLocation
import MapKit
import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var premiumManager = PremiumManager()
    @State private var isSettingsViewPresented = false
    @State private var isSearchResultsPresented = false
    @State var fakeRoute: MKRoute?
    @State var route: MKRoute?
    @State var distance: LocalizedStringKey?
    @State var minutes: LocalizedStringKey?
    @State private var showRouteConfirmation = false
    @State private var isSavedDestinationsPresented = false
    @Binding var hasLaunchedBefore: Bool
    @State var fakeUserCoordinate = CLLocationCoordinate2D(
        latitude: 34.015299,
        longitude: -118.497400
    )
    let fakeDestinationCoordinate = CLLocationCoordinate2D(latitude: 34.012900, longitude: -118.491400)

    @State var mapCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.013733, longitude: -118.494965),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    ))

    @State private var onboardingStep: Int = 0

    var body: some View {
        MapReader { _ in
            ZStack(alignment: .center) {
                Map(
                    position: $mapCameraPosition,
                    interactionModes: .all,
                    content: {
                        Annotation(
                            LocalizedStringKey("You"),
                            coordinate: fakeUserCoordinate
                        ) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(width: 20, height: 20)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }

                        MapCircle(
                            center: fakeUserCoordinate,
                            radius: 250
                        )
                        .foregroundStyle(mapViewModel.circleColor)

                        if onboardingStep >= 1 {
                            Annotation(
                                LocalizedStringKey("Your Destination"),
                                coordinate: fakeDestinationCoordinate
                            ) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                            }
                        }

                        if let fakeRoute {
                            MapPolyline(fakeRoute.polyline)
                                .stroke(Color.blue, lineWidth: 5)
                        }
                    }
                ).allowsHitTesting(false)

                VStack {
                    Spacer()

                    TextField(
                        "Search for a place...",
                        text: $mapViewModel.searchQuery
                    )
                    .textFieldStyle(
                        CustomTextFieldStyle(searchQuery: $mapViewModel.searchQuery)
                    )
                    .padding(.horizontal, 12)

                    HStack {
                        Spacer()

                        Button {
                            isSettingsViewPresented.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.oppositePrimary)
                        )
                        .shadow(radius: 30)

                        Button {
                            mapViewModel.isDestinationLocked.toggle()
                        } label: {
                            Image(systemName: mapViewModel.isDestinationLocked ? "lock.fill" : "lock.open.fill")
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.oppositePrimary)
                        )
                        .shadow(radius: 30)

                        Button {
                            isSavedDestinationsPresented.toggle()
                        } label: {
                            Image(systemName: mapViewModel.savedDestinations.count > 0 ? "bookmark.fill" : "bookmark")
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.oppositePrimary)
                        )
                        .shadow(radius: 30)
                    }
                    .padding(.bottom, 6)
                    .padding(.trailing, 14)
                }
                .allowsHitTesting(false)
                .frame(width: 380)
                .sheet(isPresented: $isSavedDestinationsPresented) {
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
                                    isSavedDestinationsPresented.toggle()
                                    mapViewModel.destination = destination
                                    showRouteConfirmation.toggle()
                                    mapViewModel.centerPositionToLocation(position: destination.coordinate)
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
                                Button {} label: {
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

                    } else {
                        VStack {
                            Text("😔")
                                .font(.largeTitle)
                            Text("There is no saved destinations yet.")
                        }.presentationDetents([PresentationDetent.medium])
                    }
                }
                .sheet(isPresented: $isSearchResultsPresented) {
                    if !mapViewModel.searchResults.isEmpty {
                        List(mapViewModel.searchResults, id: \.self) { item in
                            Button {
                                mapViewModel
                                    .centerPositionToLocation(
                                        position: item.placemark.coordinate
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
                                mapViewModel.searchQuery = ""

                                if let currentLocation = locationManager.currentLocation {
                                    mapViewModel
                                        .calculateRoute(
                                            from: currentLocation.coordinate,
                                            to: item.placemark.coordinate
                                        )
                                }

                                isSearchResultsPresented.toggle()
                                showRouteConfirmation.toggle()
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown")
                                        .font(.headline)
                                    Text(item.placemark.title ?? "")
                                        .font(.subheadline)
                                }
                            }
                        }.presentationDetents([PresentationDetent.medium])
                    }
                }
                .mapControls {
                    MapScaleView()
                    MapPitchToggle()
                    MapUserLocationButton()
                    MapCompass()
                }
                .sheet(isPresented: $showRouteConfirmation) {
                    if onboardingStep == 2 {
                        MarkedLocationSheetView(
                            isOnboarding: true,
                            locationManager: locationManager,
                            mapViewModel: mapViewModel,
                            premiumManager: premiumManager,
                            distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                            minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                            coordinates: fakeDestinationCoordinate,
                            route: $route
                        ).onTapGesture {
                            showRouteConfirmation = false
                        }

                        .presentationDetents([PresentationDetent.medium])
                        .presentationDragIndicator(.hidden)
                    }
                }

                if onboardingStep < 4 {
                    OnboardingOverlayView(step: onboardingStep) {
                        onboardingStep += 1
                        if onboardingStep == 2 { showRouteConfirmation.toggle() }
                        if onboardingStep == 2 {
                            mapViewModel.calculateRoute(from: fakeUserCoordinate, to: fakeDestinationCoordinate)
                            fakeRoute = mapViewModel.route
                        }
                        if onboardingStep == 3 {
                            locationManager.playAlert(seconds: 2)

                            let targetCoordinate = CLLocationCoordinate2D(latitude: 34.014030, longitude: -118.492400)
                            let stepCount = 60
                            let delay = 0.02

                            let latitudeStep = (targetCoordinate.latitude - fakeUserCoordinate.latitude) / Double(stepCount)
                            let longitudeStep = (targetCoordinate.longitude - fakeUserCoordinate.longitude) / Double(stepCount)

                            for step in 1 ... stepCount {
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(step)) {
                                    withAnimation(.easeInOut(duration: delay)) {
                                        fakeUserCoordinate.latitude += latitudeStep
                                        fakeUserCoordinate.longitude += longitudeStep
                                    }
                                }
                            }
                        }
                        if onboardingStep == 4 {
                            hasLaunchedBefore = true
                            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                            dismiss()
                        }

                    }.frame(maxHeight: .infinity)
                }
            }
        }.onAppear {
            mapViewModel
                .fetchAddress(for: fakeDestinationCoordinate) { fakeAddress in
                    mapViewModel
                        .calculateRoute(
                            from: fakeUserCoordinate,
                            to: fakeDestinationCoordinate
                        )
                    mapViewModel.destination = Destination(
                        address: fakeAddress,
                        coordinate: fakeDestinationCoordinate
                    )
                }
            
                
            
           
        }
    }
}

#Preview {
    OnboardingView(hasLaunchedBefore: .constant(false))
}
