import CoreLocation
import GoogleMobileAds
import MapKit
import SwiftUI

struct ContentView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var premiumManager = PremiumManager()
    @State private var isSettingsViewPresented = false
    @State private var isMarkedLocationSheetViewPresented = false
    @State private var isSavedDestinationsViewPresented = false
    @State private var isSearchResultsPresented = false
    @Binding var hasLaunchedBefore: Bool
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .center) {
            if locationManager.isLocationAuthorized {
                MapView(
                    mapViewModel: mapViewModel,
                    locationManager: locationManager,
                    premiumManager: premiumManager
                )
            } else {
                LocationPermissionView(
                    mapViewModel: mapViewModel,
                    locationManager: locationManager,
                    premiumManager: premiumManager
                )
            }
            VStack {
                VStack {
                    Spacer()
                    SearchView(
                        mapViewModel: mapViewModel,
                        locationManager: locationManager,
                        isSearchResultsPresented: $isSearchResultsPresented
                    )

                    UtilityButtonsView(
                        mapViewModel: mapViewModel,
                        locationManager: locationManager,
                        isSettingsViewPresented: $isSettingsViewPresented,
                        isSavedDestinationsViewPresented: $isSavedDestinationsViewPresented
                    )
                }
                .frame(width: 380)
                if !premiumManager.isPremium {
                    Spacer()
                    BannerViewContainer(currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width))
                        .frame(height: currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width).size.height)
                }
            }
            .sheet(isPresented: $isSavedDestinationsViewPresented) {
                SavedDestinationsView(
                    mapViewModel: mapViewModel,
                    locationManager: locationManager,
                    premiumManager: premiumManager,
                    isMarkedLocationSheetViewPresented: $isMarkedLocationSheetViewPresented
                )
        
            }
            .sheet(isPresented: $isSearchResultsPresented) {
                SearchResultsView(
                    mapViewModel: mapViewModel,
                    locationManager: locationManager,
                    isSearchResultsPresented: $isSearchResultsPresented,
                    isMarkedLocationSheetPresented: $isMarkedLocationSheetViewPresented
                ).presentationDetents([.medium])
            }
            .sheet(isPresented: $isMarkedLocationSheetViewPresented) {
                MarkedLocationSheetView(
                    locationManager: locationManager,
                    mapViewModel: mapViewModel,
                    premiumManager: premiumManager,
                    distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                    minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                    coordinates: mapViewModel.destination?.coordinate,
                    route: $mapViewModel.route
                )

                .presentationDetents([.medium])
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
                    mapViewModel.stopNavigation()
                    locationManager.resetDestination()
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

            .mapControls {
                MapScaleView()
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
            }

            .onChange(of: mapViewModel.destination) { _, newValue in
                if newValue == nil {
                    locationManager.stopBackgroundUpdatingLocation()
                } else {
                    locationManager.startBackgroundUpdatingLocation()
                }
            }

            .onAppear {
                print(mapViewModel.isDeveloperMode, "devmode")
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
        .onChange(of: scenePhase) { _, newPhase in
            locationManager.handleScenePhase(newPhase)
        }
        .onChange(of: mapViewModel.isNavigationStarted) { _, isStarted in
            locationManager.setNavigationActive(isStarted)
        }
    }
}

#Preview {
    ContentView(hasLaunchedBefore: .constant(true))
}


