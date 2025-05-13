//
//  MarkedLocationSheetView.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 13.05.2025.
//

import SwiftUI
import MapKit

struct MarkedLocationSheetView: View {
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss

    var locationTitle: String
    var distanceToUser: String
    var minutesToUser: String
    var address: Address?
    var coordinates: CLLocationCoordinate2D?
    @Binding var route: MKRoute?
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(locationTitle)
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("Marked Location - \(distanceToUser) away")
           
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Details")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
        
                Text("Address")
                    .fontWeight(.bold)
                Text(
                    [
                        address?.name,
                        address?.subLocality,
                        address?.locality,
                        address?.city,
                        address?.country,
                        address?.postalCode
                    ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                )
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        
                Divider()
                
                if let coordinates = coordinates {
                    Text("Coordinates")
                        .fontWeight(.bold)
                    Text("\(coordinates.latitude), \(coordinates.longitude)")
                }
                
            }
      
             
                    
            Spacer()
            
           
                HStack {
                    Spacer()
                    
                    Button {
                            dismiss()
                            mapViewModel.isDestinationLocked = true
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
                        
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "play.fill")
                            Text(minutesToUser)
                                .bold()
                        }
                        .frame(width: 100, height: 70)
                        .foregroundStyle(.background)
                        
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    
                    Button {
                        // Save Marker
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "bookmark.fill")
                            Text("Save")
                                .bold()
                        }
                        .frame(width: 100, height: 70)
                        .foregroundStyle(.background)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    
                    Button {
                        dismiss()
                        mapViewModel.destination = nil
                        locationManager.destinationCoordinate = nil
                        route = nil
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "x.square.fill")
                            Text("Cancel")
                                .bold()
                        }
                        .frame(width: 100, height: 70)
                        .foregroundStyle(.background)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                    }
                    Spacer()
                }
            
        }
        .padding()
        .onDisappear {
            if !mapViewModel.isDestinationLocked {
                   mapViewModel.destination = nil
                   locationManager.destinationCoordinate = nil
                   route = nil
               }
        }
    }
}

//#Preview {
//    VStack {
//
//    }.sheet(isPresented: .constant(true)) {
//        MarkedLocationSheetView(
//            locationManager: LocationManager(),
//            mapViewModel: MapViewModel(),
//            locationTitle: "Kızılay Ankara Türkiye Çankaya",
//            distanceToUser: "1.5 km",
//            minutesToUser: "9 min",
//            address: "Ankara Siteler Mobilyacılar Sanayi Sitesi Kopca Cd. 105B 06360 Altindag Ankara Turkiye",
//            coordinates: CLLocationCoordinate2D(
//                latitude: 39,
//                longitude: 24
//            ),
//            route: .constant(MKRoute())
//        )
//            .presentationDetents([PresentationDetent.medium])
//            .presentationDragIndicator(.visible)
//
//    }
//}
