import SwiftUI

struct OnboardingOverlayView: View {
    var step: Int
    var nextStep: () -> Void

    var body: some View {
        VStack {
            VStack {
                ProgressView(value: Double(step + 1), total: 4)
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 40)
                    .tint(.primary)

                Text(stepText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .cornerRadius(10)
                    .foregroundColor(Color.primary)

                Button("Next") {
                    nextStep()
                }
                .padding()
                .background(Color.oppositePrimary)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }

        .padding()
    }

    var stepText: LocalizedStringKey {
        switch step {
        case 0:
            "You can track your location on this map."
        case 1:
            "You can set a destination by clicking anywhere on the map."
        case 2:
            "When you set a destination, you can view the information of your destination and activate the alarm by pressing the start button."
        case 3:
            "When the blue circle touches your target, your device will vibrate and notify you as long as the app is open in the background."
        default:
            ""
        }
    }
}

#Preview {
    ZStack {
        Rectangle().fill(Color.gray)

        OnboardingOverlayView(step: 1) {}
    }
}
