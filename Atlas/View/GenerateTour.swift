//
//  GenerateTour.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import SwiftUI

struct GenerateTour: View {
    // MARK: - Enums
    enum AtlasState {
        case none
        case thinking
    }
    
    // MARK: - View States
    @State private var state: AtlasState = .none
    @State private var userInput = ""
    
    // MARK: - Animation Properties
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .init(x: 0.5, y: 0.5)
    @State private var gradientSpeed: Float = 0.03
    @State private var maskTimer: Float = 0.0
    
    // MARK: - Loading Message Properties
    @State private var currentMessageIndex = 0
    @State private var displayedText = ""
    @State private var isAnimating = false
    @State private var isDeleting = false
    @State private var prompt: String = ""
    @State private var timer: Timer?
    @FocusState private var isFocused: Bool
    
    // MARK: - Loading Messages
    private let loadingMessages = [
        "Fasten your seatbelt, we're checking your trip details!",
        "Locating you... Are you at the beach or in the mountains?",
        "Clouds are in the forecast... or maybe a trip?",
        "Your trip is coming... Hold tight!",
        "Are we there yet? Just kidding, still loading.",
        "Fetching the perfect vacation weather (crossing our fingers)!",
        "Your adventure is almost ready, just need to check the clouds.",
        "Gathering your luggage... virtual luggage, of course.",
        "Hope you packed sunscreen... loading your trip info!",
        "Making sure the clouds are clear for takeoff!"
    ]
    
    // MARK: - Computed Properties
    /// Determines the opacity of the background scrim based on current state
    private var scrimOpacity: Double {
        switch state {
        case .none:
            return 0
        case .thinking:
            return 0.8
        }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Colorful animated gradient
                MeshGradientView(maskTimer: $maskTimer, gradientSpeed: $gradientSpeed)
                    .scaleEffect(1.3) // avoids clipping
                    .opacity(containerOpacity)
                
                // Brightness rim on edges
                if state == .thinking {
                    RoundedRectangle(cornerRadius: 52, style: .continuous)
                        .stroke(Color.white, style: .init(lineWidth: 4))
                        .blur(radius: 4)
                }
                
                ZStack {
                    // Background Image
                    Image("wallpaper")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.2) // avoids clipping
                        .ignoresSafeArea()
                    
                    // Scrim Overlay
                    Rectangle()
                        .fill(Color.black)
                        .opacity(scrimOpacity)
                        .scaleEffect(1.2) // avoids clipping
                    
                    VStack {
                        loadingText
                        inputFieldAndButton
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .onPressingChanged { point in
                        if let point {
                            origin = point
                            counter += 1
                        }
                    }
                    .onAppear {
                        // Start the timer when the view appears
                        startLoadingCycle()
                    }
                    .onDisappear {
                        // Invalidate the timer when the view disappears
                        timer?.invalidate()
                    }
                }
                .mask {
                    AnimatedRectangle(size: geometry.size, cornerRadius: 48, t: CGFloat(maskTimer))
                        .scaleEffect(computedScale)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .blur(radius: animatedMaskBlur)
                }
            }
        }
        .ignoresSafeArea()
        //.modifier(RippleEffect(at: origin, trigger: counter))
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - View Components
    /// Displays animated loading text when in thinking state
    @ViewBuilder
    private var loadingText: some View {
        if state == .thinking {
            Text(displayedText)
                .foregroundStyle(Color.white)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.bold)
                .scaleEffect(state == .thinking ? 1.1 : 1)  // Scale effect for added emphasis
                .opacity(state == .thinking ? 1 : 0) // Fade in or fade out based on state
                .animation(.easeInOut(duration: 0.3), value: state)  // Smooth fade and scale animation
                .contentTransition(.opacity)  // Ensures opacity transition
                .transition(.opacity) // Makes sure the text fades in/out with a smooth transition
        }
    }
    
    /// Input field and send button layout
    @ViewBuilder
    private var inputFieldAndButton: some View {
        HStack {
            // Temporarily replace TextField with Text for testing
            TextField("Enter something...", text: $prompt)
                        .focused($isFocused) // Bind the focus state
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .font(.title3)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .padding(.leading, 20)
            
            // "Send" Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.9)) {
                    switch state {
                    case .none:
                        state = .thinking
                        userInput = "" // Clear input when changing to thinking state
                    case .thinking:
                        state = .none
                    }
                }
            }) {
                Text("Send")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green)
                    )
                    .foregroundColor(.white)
            }
            .padding(.trailing, 20)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 64)
    }

    // MARK: - Helper Functions
    /// Starts the animation timer for mask effect
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            DispatchQueue.main.async {
                maskTimer += rectangleSpeed
            }
        }
    }
    
    /// Initiates the loading message cycle with typewriter animation
    private func startLoadingCycle() {
        // Increase cycle duration to 8 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            startTypewriterAnimation(toIndex: (currentMessageIndex + 1) % loadingMessages.count)
        }
        // Start initial animation
        startTypewriterAnimation(toIndex: currentMessageIndex)
    }
    
    /// Animates text with typewriter effect
    /// - Parameter toIndex: Index of the next message to display
    private func startTypewriterAnimation(toIndex nextIndex: Int) {
        let currentMessage = loadingMessages[currentMessageIndex]
        isAnimating = true
        
        // First, delete the current text
        var deletingIndex = currentMessage.count
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if deletingIndex > 0 {
                deletingIndex -= 1
                displayedText = String(currentMessage.prefix(deletingIndex))
            } else {
                timer.invalidate()
                currentMessageIndex = nextIndex
                // Then, write the new text
                let newMessage = loadingMessages[currentMessageIndex]
                var typingIndex = 0
                
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                    if typingIndex < newMessage.count {
                        let index = newMessage.index(newMessage.startIndex, offsetBy: typingIndex)
                        displayedText += String(newMessage[index])
                        typingIndex += 1
                    } else {
                        timer.invalidate()
                        isAnimating = false
                    }
                }
            }
        }
    }
    
    // MARK: - Animation Helpers
    private var computedScale: CGFloat {
        switch state {
        case .none: return 1.2
        case .thinking: return 1
        }
    }
    
    private var rectangleSpeed: Float {
        switch state {
        case .none: return 0
        case .thinking: return 0.03
        }
    }
    
    private var animatedMaskBlur: CGFloat {
        switch state {
        case .none: return 8
        case .thinking: return 28
        }
    }
    
    private var containerOpacity: CGFloat {
        switch state {
        case .none: return 0
        case .thinking: return 1.0
        }
    }
}

#Preview {
    GenerateTour()
}
