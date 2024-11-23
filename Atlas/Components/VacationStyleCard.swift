
import SwiftUI

struct VacationStyleCard: View {
    let style: VacationStyle
    let width: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: style.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    GeometryReader { geo in
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: geo.size.width * 0.8)
                            .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.2)
                            .blur(radius: 30)
                    }
                }
                .frame(width: width, height: 400) // Reduced from 500
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(style.name)
                    .font(.title.bold())
                Text(style.description)
                    .font(.title3)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(width: width, height: 380) // Reduced from 480
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 3)
        }
    }
}