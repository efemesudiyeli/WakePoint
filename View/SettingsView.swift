//
//  SettingsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 5.05.2025.
//
import RevenueCat
import RevenueCatUI
import StoreKit
import SwiftUI

struct SettingsView: View {
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Bindable var premiumManager: PremiumManager
    @State var isPaywallPresented: Bool = false
    @State var isCodeRedemptionPresented: Bool = false

    var body: some View {
        List {
            Section(header: HStack(spacing: 2) {
                Text("Premium")
                .foregroundStyle(
                    Gradient(
                        colors: [
                            Color.indigo,
                            Color.white,
                        ]
                    )
                )
                Text("Customizations")
            }) {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Circle Distance")
                            .font(.headline)
                        Picker("", selection: $locationManager.circleDistance) {
                            ForEach(CircleDistance.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { distance in
                                Text("\(Int(distance.rawValue)) m").tag(distance)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .listRowInsets(EdgeInsets())
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alert Time")
                            .font(.headline)
                        Picker("", selection: $locationManager.vibrateSeconds) {
                            ForEach(VibrateSeconds.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { distance in
                                Text("\(Int(distance.rawValue)) seconds").tag(distance)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: locationManager.vibrateSeconds) { _, newValue in
                            locationManager.vibrateSeconds = newValue
                            locationManager.saveSettings()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .listRowInsets(EdgeInsets())
                Section(header: Text("Alert Type").bold()) {
                    Picker("Alert Type", selection: $locationManager.alertType) {
                        Text("Vibration").tag(LocationManager.AlertType.vibration)
                        Text("Sound").tag(LocationManager.AlertType.sound)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: locationManager.alertType) { _, newValue in
                        locationManager.alertType = newValue
                        locationManager.saveSettings()
                    }
                }
                
                ColorPicker("**Color**", selection: $mapViewModel.circleColor, supportsOpacity: true)

                
            }

            
            .allowsHitTesting(premiumManager.isPremium)
            .opacity(premiumManager.isPremium ? 1.0 : 0.5)

            Button {
                isCodeRedemptionPresented.toggle()
            } label: {
                Text("Redeem Promotion Code")
            }

            if !premiumManager.isPremium {
                Section {
                    Button {
                        isPaywallPresented.toggle()
                    } label: {
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
        .presentationBackgroundInteraction(.disabled)
        .presentationDragIndicator(.visible)
        .listStyle(.insetGrouped)
        .offerCodeRedemption(isPresented: $isCodeRedemptionPresented) { result in
            print(result)
        }
        .fullScreenCover(isPresented: $isPaywallPresented) {
            PaywallView().onDisappear {
                premiumManager.checkPremiumStatus()
            }
        }
        .onChange(of: locationManager.circleDistance) { _, newValue in
            locationManager.circleDistance = newValue
            locationManager.saveSettings()
        }
        .onChange(of: mapViewModel.circleColor) {
            _,
                _ in
            UserDefaults.standard
                .set(
                    Color.toHex(mapViewModel.circleColor)(),
                    forKey: "CircleColor"
                )
        }
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
