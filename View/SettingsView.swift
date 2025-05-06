//
//  SettingsView.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 5.05.2025.
//
import SwiftUI

struct SettingsView: View {
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    
    var body: some View {
        List {
            Section {
                Picker("Circle Distance",   selection: $locationManager.vibrateDistance) {
                    ForEach(CircleDistance.allCases.sorted(by: { $0.rawValue < $1.rawValue }),id: \.self) { distance in
                        Text("\(Int(distance.rawValue)) m")
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: locationManager.vibrateDistance) { _, newValue in
                    locationManager.vibrateDistance = newValue
                }
                
                ColorPicker("Color", selection: $mapViewModel.circleColor, supportsOpacity: true)
                
            } header: {
                Text("Circle Settings")
            }
            
            Section {Picker("Vibration Time",selection: $locationManager.vibrateSeconds) {
                    ForEach(VibrateSeconds.allCases.sorted(by: { $0.rawValue < $1.rawValue }),id: \.self) { distance in
                        Text("\(Int(distance.rawValue)) seconds")
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: locationManager.vibrateSeconds) { _, newValue in
                    locationManager.vibrateSeconds = newValue
                }
            } header: {
                Text("Vibration Time")
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    SettingsView(
        locationManager: LocationManager(),
        mapViewModel: MapViewModel()
    )
}
