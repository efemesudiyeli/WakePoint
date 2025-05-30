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
    @Environment(\.dismiss) private var dismiss
    @Bindable var locationManager: LocationManager
    @Bindable var mapViewModel: MapViewModel
    @Bindable var premiumManager: PremiumManager
    @State var isPaywallPresented: Bool = false
    @State var isCodeRedemptionPresented: Bool = false
    @State var isRestorePurchaseAlertPresented: Bool = false
    

    func requestReviewIfAppropriate() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    var body: some View {
        ZStack {
            
      
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
                        HStack {
                            Image(systemName: "circle.circle")
                            Text("Circle Distance")
                                .font(.headline)
                        }
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
                        HStack {
                            Image(systemName: "timer")
                            Text("Alert Time")
                                .font(.headline)
                        }
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
                Section {
                     HStack {
                         Image(systemName: "bell")
                         Text("Alert Type").font(.headline)
                     }
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
                ColorPicker(
                    selection: $mapViewModel.circleColor,
                    supportsOpacity: true) {
                        HStack {
                            Image(systemName: "paintpalette")
                            Text("Color").font(.headline)
                        }
                    }
            }

            .allowsHitTesting(premiumManager.isPremium)
            .opacity(premiumManager.isPremium ? 1.0 : 0.5)

            Section {
                Button {
                    isCodeRedemptionPresented.toggle()
                } label: {
                    HStack {
                        Image(systemName: "gift")
                        Text("Redeem Promotion Code")
                    }
                }
                
                Button {
                    premiumManager.tryRestorePurchases() { success in
                        if success {
                            isRestorePurchaseAlertPresented = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                        Text("Restore Purchases")
                    }
                }
                
                Button {
                    requestReviewIfAppropriate()
                } label: {
                    HStack {
                        Image(systemName: "star")
                        Text("Rate This App")
                    }
                }
                
                if !premiumManager.isPremium {
                    Section {
                        Button {
                            isPaywallPresented.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "star.circle")
                                Text("Buy Premium")
                            }
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
                    Button {
                        premiumManager.isPremium.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Toggle Premium \(premiumManager.isPremium)")
                        }
                    }
                }
            } header: {
                Text("Feedback & Extras")
            }

           
        }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundStyle(.gray)
            }.frame(width: 25, height: 25)
        }
        .alert(
            "Purchase Restored",
            isPresented: $isRestorePurchaseAlertPresented,
            actions: {
                Text("OK")
            }
        )
        .padding([.top,.horizontal])
        .interactiveDismissDisabled()
        .presentationDetents([PresentationDetent.medium])
        .presentationBackgroundInteraction(.disabled)
        .presentationDragIndicator(.hidden)
        .listStyle(.insetGrouped)
        .offerCodeRedemption(isPresented: $isCodeRedemptionPresented) { result in
            print(result)
        }.onChange(of: isCodeRedemptionPresented) { _, newValue in
            if !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    premiumManager.checkPremiumStatus()
                }
            }
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
