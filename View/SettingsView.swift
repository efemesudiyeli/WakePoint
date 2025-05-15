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
                Picker("Circle Distance", selection: $locationManager.circleDistance) {
                    ForEach(CircleDistance.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { distance in
                        Text("\(Int(distance.rawValue)) m")
                            .tag(distance)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: locationManager.circleDistance) { _, newValue in
                    locationManager.circleDistance = newValue
                    locationManager.saveSettings()
                }

                ColorPicker("Color", selection: $mapViewModel.circleColor, supportsOpacity: true)
                    .onChange(of: mapViewModel.circleColor) {
                        _,
                            _ in
                        UserDefaults.standard
                            .set(
                                Color.toHex(mapViewModel.circleColor)(),
                                forKey: "CircleColor"
                            )
                    }

            } header: {
                Text("Circle Settings")
            }

            Section { Picker("Vibration Time", selection: $locationManager.vibrateSeconds) {
                ForEach(VibrateSeconds.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { distance in
                    Text("\(Int(distance.rawValue)) seconds")
                        .tag(distance)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: locationManager.vibrateSeconds) { _, newValue in
                locationManager.vibrateSeconds = newValue
                locationManager.saveSettings()
            }
            } header: {
                Text("Vibration Time")
            }
        }
        .listStyle(.insetGrouped)
        .onAppear {
            locationManager.fetchSettings()
        }
    }
}

#Preview {
    SettingsView(
        locationManager: LocationManager(),
        mapViewModel: MapViewModel()
    )
}
