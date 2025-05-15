import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var premiumManager = PremiumManager()
    @State private var isSettingsViewPresented = false
    @State private var isSearchResultsPresented = false
    @State var route: MKRoute?
    @State private var showRouteConfirmation = false
    @State private var isSavedDestinationsPresented = false

    var body: some View {
        MapReader { reader in
            ZStack(alignment: .bottomTrailing) {
                Map(
                    position: $mapViewModel.position,
                    interactionModes: .all,
                    content: {
                        UserAnnotation()

                        if let currentLocationCoordinate = locationManager.currentLocation?.coordinate {
                            MapCircle(
                                center: currentLocationCoordinate,
                                radius: locationManager.circleDistance.rawValue
                            ).foregroundStyle(mapViewModel.circleColor)
                        }

                        if let destination = mapViewModel.destination {
                            Annotation(
                                mapViewModel.destination?.name ?? "Destination",
                                coordinate: destination.coordinate
                            ) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                }
                            }
                        }

                        if let route = route {
                            MapPolyline(route.polyline)
                                .stroke(Color.blue, lineWidth: 5)
                        }
                    }
                )

                HStack {
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

                TextField(
                    "Search for a place...",
                    text: $mapViewModel.searchQuery
                )
                .textFieldStyle(CustomTextFieldStyle())
                .padding(12)
                .padding(.bottom, 44)
                .onSubmit {
                    mapViewModel.search()
                    isSearchResultsPresented = true
                }
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

                        List(
                            mapViewModel.savedDestinations,
                            id: \.id
                        ) { destination in
                            Button {
                                isSavedDestinationsPresented.toggle()
                                mapViewModel.destination = destination
                                showRouteConfirmation.toggle()
                                mapViewModel
                                    .centerPositionToLocation(
                                        position: destination
                                            .coordinate)

                            } label: {
                                DestinationButtonView(destination: destination)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    mapViewModel
                                        .deleteDestination(
                                            destination: destination
                                        )
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }.presentationDetents([PresentationDetent.medium])

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

                                if let currentLocation = locationManager.currentLocation {
                                    mapViewModel
                                        .calculateRoute(
                                            from: currentLocation.coordinate,
                                            to: item.placemark.coordinate
                                        ) { distance, minutes in
                                            mapViewModel.destinationDistance = distance
                                            mapViewModel.destinationDistanceMinutes = minutes
                                        }
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
            }
            .mapControls {
                MapScaleView()
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
            }
            .sheet(isPresented: $showRouteConfirmation) {
                MarkedLocationSheetView(
                    locationManager: locationManager,
                    mapViewModel: mapViewModel,
                    premiumManager: premiumManager,
                    locationTitle: mapViewModel.destination?.name ?? "Title not available",
                    distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                    minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                    address: mapViewModel.destination?.address,
                    coordinates: mapViewModel.destination?.coordinate,
                    route: $route
                )
                .presentationDetents([PresentationDetent.medium])
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $isSettingsViewPresented) {
                SettingsView(
                    locationManager: locationManager,
                    mapViewModel: mapViewModel
                )
                .presentationDetents([PresentationDetent.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(
                isPresented: $locationManager.isUserReachedDistance,
                onDismiss: {
                    mapViewModel.resetDestination()
                    locationManager.resetDestination()
                    route = nil
                },
                content: {
                    VStack {
                        Spacer()
                        Text("Wake up you reached your destination nearly!")
                        Spacer()
                    }
                    .presentationDetents([PresentationDetent.medium])
                    .presentationDragIndicator(.visible)
                }
            )
            .onTapGesture { screenCoord in
                if let tappedCoord = reader.convert(screenCoord, from: .local) {
                    if mapViewModel.isDestinationLocked { return }
                    mapViewModel.destination = Destination(
                        coordinate: tappedCoord
                    )
                    showRouteConfirmation = true

                    mapViewModel.fetchAddress(for: tappedCoord) { address in
                        mapViewModel.destination?.address = address
                        mapViewModel.destination?.name = address?.name
                    }

                    if let userCoordinate = locationManager.currentLocation?.coordinate {
                        mapViewModel
                            .calculateRoute(
                                from: userCoordinate,
                                to: tappedCoord
                            ) { distance, minutes in
                                mapViewModel.destinationDistance = distance
                                mapViewModel.destinationDistanceMinutes = minutes
                            }
                    }
                }
            }
            .onAppear {
                locationManager.fetchSettings()
                mapViewModel.fetchSettings()
                mapViewModel.loadDestinations()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    MapView()
}
