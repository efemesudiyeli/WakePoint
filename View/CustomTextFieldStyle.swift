//
//  CustomTextFieldStyle.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 15.05.2025.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .oppositePrimary
    var cornerRadius: CGFloat = 8
    @Binding var searchQuery: String

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            configuration

            Button {
                searchQuery = ""
            } label: {
                Text("x")
            }.disabled(searchQuery.isEmpty)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius))
        .shadow(radius: 10)
    }
}
