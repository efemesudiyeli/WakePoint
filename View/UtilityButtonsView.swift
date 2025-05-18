//
//  UtilityButtonsView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import SwiftUI

struct UtilityButtonsView: View {
    @Bindable var mapViewModel: MapViewModel
    @Binding var isSettingsViewPresented: Bool
    @Binding var isSavedDestinationsViewPresented: Bool

    var body: some View {
        HStack {
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
        .padding(.trailing, 14)
    }
}
