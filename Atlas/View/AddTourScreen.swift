import SwiftUI
import MapKit
import SwiftData

struct AddTourScreen: View {
    enum AtlasState {
        case none
        case thinking
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

    @State private var days = 1
    @State private var currentStep = 1
    @State private var selectedCity: City?
    @State private var selectedStyle: VacationStyle?
    @State private var selectedCityIndex = 0
    @State private var selectedStyleIndex = 0
    @State private var startDate = Date()

    @State private var navigateToPlaceDetail = false
    @State private var createdTour: Tour?
    @State private var state: AtlasState = .none
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var displayedText = ""
    @State private var currentMessageIndex = 0
    @State private var isAnimating = false
    @State private var maskTimer: Float = 0.0
    @State private var timer: Timer?

    @Environment(\.modelContext) private var modelContext

    let predefinedCities = [
        City(name: "Lisbon", country: "Portugal", imageName: "lisbon"),
        City(name: "Leiria", country: "Portugal", imageName: "leiria"),
        City(name: "Madrid", country: "Spain", imageName: "madrid"),
        City(name: "Barcelona", country: "Spain", imageName: "barcelona"),
        City(name: "New York", country: "USA", imageName: "new_york"),
        City(name: "Paris", country: "France", imageName: "paris")
    ]

    let vacationStyles = [
        VacationStyle(name: "Relax", description: "Peaceful and relaxing experience", imageName: "relax",
                      colors: [.blue, .cyan]),
        VacationStyle(name: "Culture", description: "Museums, history and local traditions", imageName: "culture",
                      colors: [.purple, .indigo]),
        VacationStyle(name: "Gastronomical", description: "Local cuisine and food experiences", imageName: "food",
                      colors: [.orange, .red]),
        VacationStyle(name: "Radical", description: "Adventure and extreme sports", imageName: "radical",
                      colors: [.green, .mint]),
        VacationStyle(name: "Fun", description: "Entertainment and nightlife", imageName: "fun",
                      colors: [.pink, .purple])
    ]

    // MARK: - Computed Properties
    private var scrimOpacity: Double {
        switch state {
        case .none:
            return 0
        case .thinking:
            return 0.8
        }
    }

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

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Scrim Overlay
                    Rectangle()
                        .fill(Color.black)
                        .opacity(scrimOpacity)
                        .scaleEffect(1.2)
                    
                    // Main content
                    VStack(spacing: 24) {
                        StepIndicator(currentStep: currentStep)
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        MainContentTabView(
                            currentStep: $currentStep,
                            startDate: $startDate,
                            days: $days,
                            selectedCity: $selectedCity,
                            selectedStyle: $selectedStyle,
                            selectedCityIndex: $selectedCityIndex,
                            selectedStyleIndex: $selectedStyleIndex,
                            predefinedCities: predefinedCities,
                            vacationStyles: vacationStyles
                        )
                        
                        NavigationButtons(handleFinishButton: handleFinishButton, currentStep: $currentStep)
                            .padding()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .background(
                        LinearGradient(colors: [.primary.opacity(0.05), .clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                    .blur(radius: state == .thinking ? 200 : 0)
                    
                    // Loading text overlay
                    if state == .thinking {
                        loadingText
                    }
                }
                
                // Navigation destination
                .navigationDestination(isPresented: $navigateToPlaceDetail) {
                    if let tour = createdTour, let firstPlace = tour.places.first {
                        PlaceDetailScreen(places: tour.places, title: tour.name, placeIndex: 0)
                            .transition(.move(edge: .trailing))
                            .animation(.easeInOut, value: navigateToPlaceDetail)
                    }
                }
            }
        }
    }

    public func handleFinishButton() {
        Task {
            do {
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .thinking
                }
                startLoadingCycle() // Add this line

                let response = try await TourAPIService.shared.generateTour(prompt: "Generate tour for \(selectedCity?.name ?? "") with style \(selectedStyle?.name ?? "") for \(days) days starting from \(startDate)")
                let tour = createTour(from: response)
                createdTour = tour

                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                    navigateToPlaceDetail = true
                }
            } catch {
                showError = true
                errorMessage = error.localizedDescription

                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                }
            }
        }
    }

    private func createTour(from response: TourAPIResponse) -> Tour {
        let tour = Tour(name: "Lisbon adventures")

        let places = response.places.map { placeData in
            Place(
                coordinate: CLLocationCoordinate2D(
                    latitude: Double(placeData.coordinates[0]) ?? 0,
                    longitude: Double(placeData.coordinates[1]) ?? 0
                ),
                title: placeData.title,
                description: placeData.description,
                isLandmark: placeData.isLandmark
            )
        }

        tour.places = places
        modelContext.insert(tour)

        // Save the context
        try? modelContext.save()
        return tour
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
