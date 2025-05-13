import SwiftUI
import MapKit
import CoreLocation



struct MapView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var isSettingsViewPresented = false
    @State var isSearchResultsPresented = false
    @State var route: MKRoute?
    @State private var showRouteConfirmation = false
    
    
    
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
                            Annotation("Destination", coordinate: destination.coordinate) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if let searchPlacemark = mapViewModel.clickedLocationOnSearch {
                            Annotation(
                                (searchPlacemark.name ?? "Search Result"),
                                coordinate: searchPlacemark.coordinate
                            ) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
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
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    .shadow(radius: 30)
                    
                    Button {
                        mapViewModel.isDestinationLocked.toggle()
                    } label: {
                        Image(systemName: (mapViewModel.isDestinationLocked ? "lock.fill" : "lock.open.fill"))
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    .shadow(radius: 30)
                }
                .padding(.bottom, 6)
                .padding(.trailing, 14)
                
                TextField(
                    "Search for a place...",
                    text: $mapViewModel.searchQuery
                )
                .textFieldStyle(.roundedBorder)
                .padding()
                .padding(.bottom, 44)
                .onSubmit {
                    mapViewModel.search()
                    isSearchResultsPresented = true
                }
                .sheet(isPresented: $isSearchResultsPresented) {
                    if !mapViewModel.searchResults.isEmpty {
                        List(mapViewModel.searchResults, id: \.self) { item in
                            Button(
                                action: {
                                    mapViewModel
                                        .centerPositionToLocation(
                                            position: item.placemark.coordinate
                                        )
                                    mapViewModel.clickedLocationOnSearch = item.placemark
                                }) {
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
            .mapControls{
                MapScaleView()
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
            }
            .sheet(isPresented: $showRouteConfirmation) {
                MarkedLocationSheetView(
                    locationManager: locationManager,
                    mapViewModel: mapViewModel,
                    locationTitle: mapViewModel.destinationAddress?.name ?? "Title not available",
                    distanceToUser: mapViewModel.destinationDistance ?? "N/A",
                    minutesToUser: mapViewModel.destinationDistanceMinutes ?? "N/A",
                    address: mapViewModel.destinationAddress,
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
                    locationManager.destinationCoordinate = tappedCoord
                    showRouteConfirmation = true
                    
                    mapViewModel.fetchAddress(for: tappedCoord) { address in
                        mapViewModel.destinationAddress = address
                    }
                    
                    if let userCoordinate = locationManager.currentLocation?.coordinate {
                        mapViewModel
                            .calculateRoute(
                                from: userCoordinate,
                                to: tappedCoord) { distance, minutes in
                                    mapViewModel.destinationDistance = distance
                                    mapViewModel.destinationDistanceMinutes = minutes
                                }
                    }
                    
                    
                }
            }
            
            .onAppear {
                locationManager.fetchSettings()
                mapViewModel.fetchSettings()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        if let userCoordinate = locationManager.currentLocation?.coordinate {
                            mapViewModel.position = MapCameraPosition.region(
                                MKCoordinateRegion(
                                    center: userCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
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
