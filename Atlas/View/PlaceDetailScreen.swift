import SwiftUI
import MapKit

struct PlaceDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var places: [Place]
    @State private var currentPlaceIndex: Int
    @State private var position: MapCameraPosition = .automatic
    @State private var heading: CLLocationDirection = 100
    private let rotationSpeed: CLLocationDirection = 0.1
    @State private var distance: CLLocationDistance
    @State private var title: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkMode: Bool
    @State private var showUnlockSheet = false
    @State private var nextStop: Place? = nil
    @State private var rotationTimer: Timer?

    // Computed property to get the current place
    private var currentPlace: Place {
        places[currentPlaceIndex]
    }

    init(places: [Place], distance: CLLocationDistance = 500, title: String, placeIndex: Int = 0) {
        _places = State(initialValue: places)
        _distance = State(initialValue: distance)
        _title = State(initialValue: title)
        _isDarkMode = State(initialValue: UITraitCollection.current.userInterfaceStyle == .dark)
        _currentPlaceIndex = State(initialValue: placeIndex)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    Map(position: $position,
                        interactionModes: [.pan, .zoom, .rotate],
                        selection: .constant(nil)) {
                        // Add markers for non-landmark places
                        ForEach(places.indices, id: \.self) { index in
                            if !places[index].isLandmark {
                                Marker(places[index].title, coordinate: places[index].coordinate)
                                    .tint(.red)
                            }
                        }
                    }
                    .onAppear {
                        updateMapCamera(for: currentPlace)
                    }
                    .mapStyle(
                        .standard(
                            elevation: .realistic,
                            pointsOfInterest: .excludingAll,
                            showsTraffic: false
                        )
                    )
                    .mapControls {
                        // Empty to disable compass while maintaining interactions
                    }
                    .ignoresSafeArea()

                    VStack {
                        VariableBlurView(maxBlurRadius: 20, direction: .blurredTopClearBottom)
                            .frame(height: proxy.safeAreaInsets.top)
                            .ignoresSafeArea()
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        VStack(spacing: 24) {
                            PillShapedIconTextButton(
                                text: "Explore more to Unlock",
                                sfSymbol: "lock.fill"
                            ) {
                                // Your action here, e.g., toggling a sheet
                                showUnlockSheet.toggle()
                            }
                            .sheet(isPresented: $showUnlockSheet) {
                                VStack {
                                    Text("Unlock Features")
                                }
                                .presentationBackground(.regularMaterial)
                            }

                            if currentPlaceIndex < places.count - 1 {
                                // Show the NextStopButton if there's a next landmark
                                NextStopButton(
                                    title: places[currentPlaceIndex + 1].title,
                                    coordinate: places[currentPlaceIndex + 1].coordinate,
                                    description: places[currentPlaceIndex + 1].description,
                                    isLandmark: places[currentPlaceIndex + 1].isLandmark,
                                    distance: 1000, // Example distance
                                    pitch: 65, // Example pitch
                                    heading: 0 // Example heading
                                ) {
                                    // Move to the next landmark
                                    goToNextLandmark()
                                }
                            }

                            Text(currentPlace.title)
                                .font(.system(size: 34, weight: .semibold))
                                .fontDesign(.serif)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: currentPlaceIndex)

                            Text(currentPlace.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: currentPlaceIndex)
                        }
                        .padding(.bottom, 120)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    Color(.systemBackground).opacity(0.6),
                                    Color(.systemBackground).opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: proxy.size.width)
                        )
                        .background(
                            VariableBlurView(maxBlurRadius: 20, direction: .blurredBottomClearTop)
                                .frame(width: proxy.size.width)
                        )
                    }
                    .ignoresSafeArea()
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(title)
                        .fontDesign(.serif)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        withAnimation {
                            isDarkMode.toggle()
                            if let window = UIApplication.shared.windows.first {
                                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                    window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                                }, completion: nil)
                            }
                        }
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                    .foregroundColor(.primary)

                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.primary)
                }
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .onDisappear {
            rotationTimer?.invalidate()
            rotationTimer = nil
        }
    }

    private func updateMapCamera(for landmark: Place) {
        // Cancel any existing timer
        rotationTimer?.invalidate()
        
        // First move to location with animation
        withAnimation(.easeInOut(duration: 2.0)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: landmark.coordinate,
                    distance: distance,
                    heading: heading,
                    pitch: 80
                )
            )
        }
        
        // Start panning after the initial animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] timer in
                heading += rotationSpeed
                if heading >= 360 {
                    heading = 0
                }
                
                position = .camera(
                    MapCamera(
                        centerCoordinate: currentPlace.coordinate,
                        distance: distance,
                        heading: heading,
                        pitch: 80
                    )
                )
            }
        }
    }

    private func goToNextLandmark() {
        if currentPlaceIndex < places.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPlaceIndex += 1
            }
            updateMapCamera(for: currentPlace)
        }
    }
}

#Preview {
    var places = [
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
            title: "Belém Tower",
            description: "A 16th-century fortified tower located in Lisbon, Portugal. Built during the Age of Discoveries, this UNESCO World Heritage site served as both a fortress and a ceremonial gateway to Lisbon.",
            isLandmark: true
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6970, longitude: -9.2033),
            title: "Pastéis de Belém",
            description: "The original home of Portugal's famous pastéis de nata, this historic pastry shop has been serving their secret-recipe custard tarts since 1837. Located near Jerónimos Monastery, it's a must-visit culinary destination.",
            isLandmark: false
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.7139, longitude: -9.1334),
            title: "São Jorge Castle",
            description: "Perched atop Lisbon's highest hill, this medieval castle dates back to the 11th century. It offers panoramic views of the city and stands as a testament to Portugal's rich history of Moorish and Christian rule.",
            isLandmark: true
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6977, longitude: -9.2063),
            title: "Jerónimos Monastery",
            description: "A magnificent example of Manueline architecture, this monastery was built in the 16th century. UNESCO-listed, it commemorates Vasco da Gama's voyage and represents the wealth of Portuguese discovery era.",
            isLandmark: true
        )
    ]
    PlaceDetailScreen(places: places, title: "Example", placeIndex: 1 )
}
