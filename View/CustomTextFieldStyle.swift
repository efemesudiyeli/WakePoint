//
//  CustomTextFieldStyle.swift
//  WakeupMap
//
//  Created by Efe Mesudiyeli on 15.05.2025.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .oppositePrimary
    var cornerRadius: CGFloat = 10
    var padding: CGFloat = 14

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            configuration
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(radius: 12)
        .padding(.bottom, 6)
    }
}
