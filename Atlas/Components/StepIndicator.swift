
import SwiftUI

struct StepIndicator: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(1...4, id: \.self) { step in
                StepDot(step: step, currentStep: currentStep)
                if step < 4 {
                    StepConnector(step: step, currentStep: currentStep)
                }
            }
        }
    }
}

struct StepDot: View {
    let step: Int
    let currentStep: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(step <= currentStep ? 
                      Color.black : Color.gray.opacity(0.3))
                .frame(width: 10, height: 10)
                .overlay {
                    if step == currentStep {
                        Circle()
                            .stroke(
                                Color.black.opacity(0.25), lineWidth: 4)    
                            .frame(width: 20, height: 20)
                    }
                }
                .animation(.spring(), value: currentStep)
            
            Text("Step \(step)")
                .font(.caption2)
                .foregroundStyle(step <= currentStep ? .primary : .secondary)
        }
    }
}

struct StepConnector: View {
    let step: Int
    let currentStep: Int
    
    var body: some View {
        Rectangle()
            .fill(step < currentStep ? 
                .black : .gray.opacity(0.2))
            .frame(height: 1)
            .animation(.spring(), value: currentStep)
    }
}