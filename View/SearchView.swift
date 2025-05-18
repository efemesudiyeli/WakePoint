//
//  SearchView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//
import SwiftUI

struct SearchView: View {
    @Bindable var mapViewModel: MapViewModel
    @Binding var isSearchResultsPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            if !mapViewModel.relatedSearchResults.isEmpty, !mapViewModel.searchQuery.isEmpty {
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(mapViewModel.relatedSearchResults, id: \.self) { item in
                            Button {
                                mapViewModel.searchQuery = item.placemark.name ?? ""
                            } label: {
                                Text(item.placemark.name ?? "location")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(4)
                    .shadow(radius: 2)
                }
                .background(Color.oppositePrimary)
                .padding(.horizontal, 12)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
            }

            TextField(
                "Search for a place...",
                text: $mapViewModel.searchQuery
            )
            .submitLabel(.search)
            .textFieldStyle(
                CustomTextFieldStyle(searchQuery: $mapViewModel.searchQuery)
            )
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Dismiss") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .padding(.horizontal, 12)
            .onChange(of: mapViewModel.searchQuery) {
                _,
                    _ in
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 0.3) {
                        mapViewModel
                            .updateRelatedSearchResults(
                                query: $mapViewModel
                                    .searchQuery.wrappedValue)
                    }
            }
            .onSubmit {
                guard !mapViewModel.searchQuery.isEmpty else { return }
                mapViewModel.search()
                isSearchResultsPresented.toggle()
            }
        }
    }
}
