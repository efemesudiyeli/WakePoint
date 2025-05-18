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
            if mapViewModel.isDestinationLocked {
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
                mapViewModel.isDestinationLocked.toggle()
            } label: {
                Image(systemName: mapViewModel.isDestinationLocked ? "lock.fill" : "lock.open.fill")
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
                mapViewModel.resetDestination()
                locationManager.resetDestination()
                mapViewModel.route = nil
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
