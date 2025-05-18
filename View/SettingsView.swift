//
//  SettingsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 5.05.2025.
//
import SwiftUI

struct SettingsView: View {
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Bindable var premiumManager: PremiumManager

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

            if !premiumManager.isPremium {
                Section {
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
                    }
                }
            }

            if mapViewModel.isDeveloperMode {
                Section {
                    Button {
                        premiumManager.isPremium.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Toggle Premium")
                            Text("\(premiumManager.isPremium)")
                        }
                    }

                } header: {
                    Text("DEVELOPER MODE")
                }
            }
        }
        .presentationDetents([PresentationDetent.medium])
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
        .listStyle(.insetGrouped)
        .onAppear {
            locationManager.fetchSettings()
        }
    }
}

#Preview {
    SettingsView(
        locationManager: LocationManager(),
        mapViewModel: MapViewModel(), premiumManager: PremiumManager()
    )
}
