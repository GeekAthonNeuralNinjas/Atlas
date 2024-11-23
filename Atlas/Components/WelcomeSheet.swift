import SwiftUI

// Helper view for feature items
struct FeatureRow: View {
    let title: String
    let description: String
    let icon: String
    let isAnimating: Bool
    let index: Int
    let animateGradient: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 36)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#FF9B82"), Color(hex: "#86B5FF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce, value: animateGradient)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .offset(x: isAnimating ? 0 : -50)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring().speed(0.5).delay(Double(index) * 0.15), value: isAnimating)
    }
}

struct WelcomeSheet: View {
    @Binding var isPresented: Bool
    @State private var animateGradient = false
    @State private var appearAnimation = false
    @State private var featuresAppear = false
    @State private var buttonAppear = false
    
    private let features = [
        (title: "Generate Custom Tours", description: "Create personalized travel itineraries with AI assistance", icon: "wand.and.stars"),
        (title: "Explore Places", description: "Discover landmarks, restaurants, and hidden gems", icon: "map"),
        (title: "Smart Planning", description: "Get weather-aware and time-optimized routes", icon: "brain.head.profile"),
    ]
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "#FF9B82").opacity(0.1),
                Color(hex: "#86B5FF").opacity(0.1)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
    }
    
    private var continueButton: some View {
        Button(action: { 
            withAnimation(.spring()) {
                isPresented = false
            }
        }) {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF9B82"), Color(hex: "#86B5FF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .scaleEffect(buttonAppear ? 1 : 0.8)
        }
        .opacity(buttonAppear ? 1 : 0)
        .animation(.spring().delay(0.5), value: buttonAppear)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1A2235")
                    .ignoresSafeArea()
                
                backgroundGradient
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
                
                VStack(spacing: 32) {
                    Image("app_icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(24)
                        .padding(.top, 32)
                        .shadow(radius: 10)
                        .scaleEffect(appearAnimation ? 1 : 0.5)
                        .opacity(appearAnimation ? 1 : 0)
                    
                    Text("Welcome to Atlas")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(features.indices, id: \.self) { index in
                            FeatureRow(
                                title: features[index].title,
                                description: features[index].description,
                                icon: features[index].icon,
                                isAnimating: featuresAppear,
                                index: index,
                                animateGradient: animateGradient
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    continueButton
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
            }
            .tint(.white)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appearAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        featuresAppear = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        buttonAppear = true
                    }
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}

#Preview {
    WelcomeSheet(isPresented: .constant(true))
}
