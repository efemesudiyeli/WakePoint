//
//  UtilityButtonsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import SwiftUI

struct UtilityButtonsView: View {
    @Bindable var mapViewModel: MapViewModel
    @Bindable var locationManager: LocationManager
    @Binding var isSettingsViewPresented: Bool
    @Binding var isSavedDestinationsViewPresented: Bool
    @State var isEndRouteConfirmationPresented: Bool = false

    var body: some View {
        HStack {
            if mapViewModel.isNavigationStarted {
                Button {
                    isEndRouteConfirmationPresented.toggle()
                } label: {
                    Text("End Route")
                        .foregroundStyle(Color.oppositePrimary)
                        .fontWeight(.heavy)
                }
                .frame(width: 100, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                )
                .shadow(radius: 30)
                .transition(.opacity)
            }

            Spacer()

            if !mapViewModel.isNavigationStarted {
                Button {
                    switch mapViewModel.routeTransportType {
                    case .automobile:
                        mapViewModel.routeTransportType = .walking
                    default:
                        mapViewModel.routeTransportType = .automobile
                    }
                } label: {
                    switch mapViewModel.routeTransportType {
                    case .automobile:
                        Image(systemName: "car.fill")
                    default:
                        Image(systemName: "figure.walk")
                    }
                }
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.oppositePrimary)
                )
                .shadow(radius: 30)
            }

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
                isSavedDestinationsViewPresented.toggle()
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
        .padding(.horizontal, 14)
        .alert(
            "End Route",
            isPresented: $isEndRouteConfirmationPresented
        ) {
            Button {
                mapViewModel.stopNavigation()
                locationManager.resetDestination()
            } label: {
                Text("Confirm")
            }

            Button(role: .cancel) {} label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure to end the current route?")
        }
    }
}
