//
//  WakeUpView.swift
//  WakePoint
//
//  Created by Efe Mesudiyeli on 18.05.2025.
//

import SwiftUI

struct WakeUpView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Wake up you reached your destination nearly!")
            Spacer()
        }
        .presentationDetents([PresentationDetent.medium])
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    WakeUpView()
}
