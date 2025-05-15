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

    var stepText: String {
        switch step {
        case 0:
            "Bu haritadan konumunuzu takip edebilirsiniz."
        case 1:
            "Harita üzerinde istediğiniz yere tıklayarak bir hedef belirleyebilirsiniz."
        case 2:
            "Hedef belirlediğinizde hedefinizin bilgilerini görüntüleyebilir ve hatırlatıcıyı başlat butonuna basarak aktif hale getirebilirsiniz."
        case 3:
            "Mavi daire hedefinize dokunduğu zaman uygulama arkaplanda açık olduğu sürece cihazınız titreyecek ve size haber verecek."
        default:
            ""
        }
    }
}

#Preview {
    ZStack {
       
        Rectangle().fill(Color.gray)
        
        OnboardingOverlayView(step: 1) {
            
        }
    }
    
}
