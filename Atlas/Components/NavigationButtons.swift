
import SwiftUI

struct NavigationButtons: View {
    @Binding var currentStep: Int
    
    var body: some View {
        HStack {
            Button(action: { withAnimation(.spring()) { currentStep -= 1 } }) {
                Label("Back", systemImage: "chevron.left")
                    .font(.body.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .opacity(currentStep == 1 ? 0 : 1)
            .disabled(currentStep == 1)
            
            Spacer()
            
            Button(action: { withAnimation(.spring()) { currentStep += 1 } }) {
                Label(currentStep < 4 ? "Next" : "Finish",
                      systemImage: currentStep < 4 ? "chevron.right" : "checkmark")
                .font(.body.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    .black
                )
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}