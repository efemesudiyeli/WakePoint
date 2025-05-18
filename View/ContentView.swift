import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var premiumManager = PremiumManager()
    @State private var isSettingsViewPresented = false
    @State private var isRouteConfirmationSheetPresented = false
    @State private var isSavedDestinationsViewPresented = false
    @State private var isSearchResultsPresented = false
    @Binding var hasLaunchedBefore: Bool

    var body: some View {
        MapReader { reader in
            ZStack(alignment: .center) {
                MapView(
                    mapViewModel: mapViewModel,
                    locationManager: locationManager
                )

                VStack {
                    Spacer()
                    SearchView(
                        mapViewModel: mapViewModel,
                        isSearchResultsPresented: $isSearchResultsPresented
                    )

                    UtilityButtonsView(
                        mapViewModel: mapViewModel,
                        isSettingsViewPresented: $isSettingsViewPresented,
                        isSavedDestinationsViewPresented: $isSavedDestinationsViewPresented
                    )
                }
                .frame(width: 380)
                .sheet(isPresented: $isSavedDestinationsViewPresented) {
                    SavedDestinationsView(
                        mapViewModel: mapViewModel,
                        locationManager: locationManager,
                        premiumManager: premiumManager,
                        isSavedDestinationsViewPresented: $isSavedDestinationsViewPresented,
                        isRouteConfirmationSheetPresented: $isRouteConfirmationSheetPresented
                    )
                }
                .sheet(isPresented: $isSearchResultsPresented) {
                    SearchResultsView(
                        mapViewModel: mapViewModel,
                        locationManager: locationManager,
                        isSearchResultsPresented: $isSearchResultsPresented,
                        isRouteConfirmationSheetPresented: $isRouteConfirmationSheetPresented
                    )
                }
                .sheet(isPresented: $isRouteConfirmationSheetPresented) {
                    MarkedLocationSheetView(
                        locationManager: locationManager,
                        mapViewModel: mapViewModel,
                        premiumManager: premiumManager,
                        locationTitle: mapViewModel.destination?.name ?? "Title not available",
                        distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                        minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                        address: mapViewModel.destination?.address,
                        coordinates: mapViewModel.destination?.coordinate,
                        route: $mapViewModel.route
                    )
                }
                .sheet(isPresented: $isSettingsViewPresented) {
                    SettingsView(
                        locationManager: locationManager,
                        mapViewModel: mapViewModel, premiumManager: premiumManager
                    )
                }
                .sheet(
                    isPresented: $locationManager.isUserReachedDistance,
                    onDismiss: {
                        mapViewModel.resetDestination()
                        locationManager.resetDestination()
                        mapViewModel.route = nil
                    }
                ) {
                    WakeUpView()
                }
                .fullScreenCover(isPresented: $hasLaunchedBefore.map { !$0 }) {
                    OnboardingView(hasLaunchedBefore: $hasLaunchedBefore)
                        .onDisappear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    if let userCoordinate = locationManager.currentLocation?.coordinate {
                                        mapViewModel.position = MapCameraPosition.region(
                                            MKCoordinateRegion(
                                                center: userCoordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            ))
                                    }
                                }
                            }
                        }
                }
            }

            .mapControls {
                MapScaleView()
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
            }
            
            .onChange(of: mapViewModel.destination, { _, newValue in
                if newValue == nil {
                    locationManager.stopBackgroundUpdatingLocation()
                } else {
                    locationManager.startBackgroundUpdatingLocation()
                }
            })

            .onTapGesture { screenCoord in
                if mapViewModel.destination == nil {
                    if let tappedCoord = reader.convert(screenCoord, from: .local) {
                        if mapViewModel.isDestinationLocked { return }
                        mapViewModel.destination = Destination(
                            coordinate: tappedCoord
                        )

                        mapViewModel.fetchAddress(for: tappedCoord) { address in
                            mapViewModel.destination?.address = address
                            mapViewModel.destination?.name = address?.name
                        }

                        if let userCoordinate = locationManager.currentLocation?.coordinate {
                            mapViewModel
                                .calculateRoute(
                                    from: userCoordinate,
                                    to: tappedCoord
                                ) { distance, minutes, _ in
                                    mapViewModel.destinationDistance = distance
                                    mapViewModel.destinationDistanceMinutes = minutes
                                }
                        }
                        isRouteConfirmationSheetPresented = true
                    }
                }
            }
            .onAppear {
                locationManager.fetchSettings()
                mapViewModel.fetchSettings()
                mapViewModel.loadDestinations()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        if let userCoordinate = locationManager.currentLocation?.coordinate {
                            mapViewModel.position = MapCameraPosition.region(
                                MKCoordinateRegion(
                                    center: userCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                ))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(hasLaunchedBefore: .constant(true))
}
