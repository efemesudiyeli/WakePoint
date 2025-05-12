import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State var locationManager = LocationManager()
    @State var mapViewModel = MapViewModel()
    @State var isSettingsViewPresented = false
    @State var isSearchResultsPresented = false
    @State var isDestinationLocked = false
    @State private var route: MKRoute?
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
                        isDestinationLocked.toggle()
                    } label: {
                        Image(systemName: (isDestinationLocked ? "lock.fill" : "lock.open.fill"))
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
                .alert("Start Navigation?", isPresented: $showRouteConfirmation) {
                    Button("Start") {
                        isDestinationLocked = true
                        let request = MKDirections.Request()
                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation?.coordinate ?? .init()))
                        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: mapViewModel.destination?.coordinate ?? .init()))
                        request.transportType = .automobile
                        
                        let directions = MKDirections(request: request)
                        directions.calculate { response, error in
                            if let route = response?.routes.first {
                                self.route = route
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        mapViewModel.destination = nil
                        locationManager.destinationCoordinate = nil
                        route = nil
                    }
                }
            }
            .mapControls{
                MapScaleView()
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
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
                    if isDestinationLocked { return }
                    mapViewModel.destination = Destination(
                        coordinate: tappedCoord
                    )
                    locationManager.destinationCoordinate = tappedCoord
                    showRouteConfirmation = true
                }
            }
            
            .onAppear {
                locationManager.fetchSettings()
                mapViewModel.fetchSettings()
            }
        }
    }
}

#Preview {
    MapView()
}
