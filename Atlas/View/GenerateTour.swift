/*import SwiftUI
import MapKit
import SwiftData

// MARK: - Models
struct TourAPIResponse: Decodable {
    let name: String
    let places: [PlaceAPIData]
}

struct PlaceAPIData: Decodable {
    let arrival: String
    let arrival_hour: String
    let city: String
    let coordinates: Coordinates
    let description: String
    let name: String
    let type: String
    let adress: String
    let duration: String
    let isLandmark: Bool
    let reason: String
}

struct Coordinates: Decodable {
    let lat: String
    let log: String
}

struct TourPrompt: Encodable {
    let city: String
    let start_date: String
    let duration: Int
    let flavour: String
}

// MARK: - Network Service
class TourAPIService {
    static let shared = TourAPIService()
    private init() {}
    
    func generateTour(prompt: TourPrompt) async throws -> TourAPIResponse {
        guard let url = URL(string: "https://atlas-api-service.xb8vmgez1emgp.us-west-2.cs.amazonlightsail.com/plan") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(prompt)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TourAPIResponse.self, from: data)
    }
}

struct GenerateTour: View {
    // MARK: - Enums
    enum AtlasState {
        case none
        case thinking
    }
    
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Navigation State
    @State private var navigateToPlaceDetail = false
    @State private var createdTour: Tour?
    
    // Previous state properties remain the same...
    @State private var state: AtlasState = .none
    @State private var userInput = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .init(x: 0.5, y: 0.5)
    @State private var gradientSpeed: Float = 0.03
    @State private var maskTimer: Float = 0.0
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
    
    // MARK: - Helper Functions
    private func createTour(from response: TourAPIResponse) -> Tour {
            let tour = Tour(name: response.name)
            
            let places = response.places.map { placeData in
                let latitude = Double(placeData.coordinates.lat.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                let longitude = Double(placeData.coordinates.log.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                
                return Place(
                    coordinate: CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    title: placeData.name,
                    description: placeData.description,
                    isLandmark: placeData.isLandmark,
                    arrival: DateFormatter().date(from: placeData.arrival) ?? Date(),
                    arrivalHour: placeData.arrival_hour,
                    city: placeData.city,
                    type: placeData.type,
                    address: placeData.adress,
                    duration: placeData.duration,
                    reason: placeData.reason
                )
            }
            
            tour.places = places
            modelContext.insert(tour)
        
            // Save the context
            try? modelContext.save()
            return tour
        }
    
    private func handleSendButton() {
        Task {
            do {
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .thinking
                }
                
                let prompt = TourPrompt(city: "Leiria", start_date: "24/12/24", duration: 2, flavour: "fun")
                print("Prompt: \(prompt)")
                
                let response = try await TourAPIService.shared.generateTour(prompt: prompt)
                let tour = createTour(from: response)
                createdTour = tour
                
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                    navigateToPlaceDetail = true
                }
                
                // Clear the prompt
                self.prompt = ""
            } catch {
                showError = true
                errorMessage = error.localizedDescription
                
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                }
            }
        }
    }
    
    // MARK: - Computed Properties
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
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Colorful animated gradient
                    MeshGradientView(maskTimer: $maskTimer, gradientSpeed: $gradientSpeed)
                        .scaleEffect(1.3)
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
                            .scaleEffect(1.2)
                            .ignoresSafeArea()
                        
                        // Scrim Overlay
                        Rectangle()
                            .fill(Color.black)
                            .opacity(scrimOpacity)
                            .scaleEffect(1.2)
                        
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
                    }
                    .mask {
                        AnimatedRectangle(size: geometry.size, cornerRadius: 48, t: CGFloat(maskTimer))
                            .scaleEffect(computedScale)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .blur(radius: animatedMaskBlur)
                    }
                }
                .navigationDestination(isPresented: $navigateToPlaceDetail) {
                    if let tour = createdTour, let firstPlace = tour.places.first {
                        PlaceDetailScreen(places: tour.places, title: tour.name, placeIndex: 0)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                startTimer()
                startLoadingCycle()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var loadingText: some View {
        if state == .thinking {
            Text(displayedText)
                .foregroundStyle(Color.white)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.bold)
                .scaleEffect(state == .thinking ? 1.1 : 1)
                .opacity(state == .thinking ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: state)
                .contentTransition(.opacity)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var inputFieldAndButton: some View {
        HStack {
            TextField("Enter something...", text: $prompt)
                .focused($isFocused)
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
            
            Button(action: handleSendButton) {
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
    
    // Rest of the animation helper functions remain the same
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
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            DispatchQueue.main.async {
                maskTimer += rectangleSpeed
            }
        }
    }
    
    private func startLoadingCycle() {
        timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
            startTypewriterAnimation(toIndex: (currentMessageIndex + 1) % loadingMessages.count)
        }
        startTypewriterAnimation(toIndex: currentMessageIndex)
    }
    
    private func startTypewriterAnimation(toIndex nextIndex: Int) {
        let currentMessage = loadingMessages[currentMessageIndex]
        isAnimating = true
        
        var deletingIndex = currentMessage.count
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if deletingIndex > 0 {
                deletingIndex -= 1
                displayedText = String(currentMessage.prefix(deletingIndex))
            } else {
                timer.invalidate()
                currentMessageIndex = nextIndex
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
}
*/
