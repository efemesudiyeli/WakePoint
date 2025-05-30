//
//  LocationPermissionView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 31.05.2025.
//


import CoreLocation
import GoogleMobileAds
import MapKit
import SwiftUI

struct LocationPermissionView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager
    @Bindable var premiumManager: PremiumManager
    
    var body: some View {
        ZStack {
            MapView(
                mapViewModel: mapViewModel,
                locationManager: locationManager,
                premiumManager: premiumManager
            )
            .blur(radius: 20)
            .allowsHitTesting(false)
            VStack {
                VStack {
                    Text("Please enable location permission.")
                        .multilineTextAlignment(.center)
                        .padding()
                        .cornerRadius(10)
                        .foregroundColor(Color.primary)
                    
                    Button("Go to settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url)
                        {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color.oppositePrimary)
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
        }
    }
}
