import SwiftUI
import MapKit
import CoreLocation

// New helper view for sheet content
private struct PlaceDetailSheet: View {
    let place: Place
    let lookaroundScene: MKLookAroundScene?
    let dismissAction: () -> Void
    @State private var weather: String = "22°C Sunny"
    @State private var openingHours: String = "09:00 - 18:00"
    @State private var distance: String = "Calculating distance..."
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Info Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            InfoPill(icon: "thermometer.sun", text: weather)
                            InfoPill(icon: "clock", text: openingHours)
                            InfoPill(icon: "location", text: distance)
                            InfoPill(icon: "star.fill", text: "4.8 (2.4k)")
                        }
                    }
                    
                    if let scene = lookaroundScene {
                        LookAroundPreview(scene: .constant(scene))
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 20)
                    } else {
                        //Map
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )))
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        HStack{
                            HStack{
                                //Spark icon
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                
                                Text("About")
                                    .font(.title2.bold())
                                    .fontDesign(.rounded)
                            }
                            Spacer()
                                Text("AI Generated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                        }

                        
                        Text(place.text)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity)
                    //Frosted Glass
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )

                    if let scene = lookaroundScene {
                         //Map
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: place.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )))
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20)
                    }
                    
                    // Action Buttons Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ActionButton(
                            icon: "car.fill",
                            text: "Directions",
                            gradient: [Color.blue, Color.purple]
                        ) {
                            openInMaps(coordinate: place.coordinate, name: place.name)
                        }
                    }
                }
                .padding(24)
            }
            .background(Color(.systemBackground))
            .navigationTitle(place.name)
            .navigationBarItems(trailing: Button("Done", action: dismissAction))
        }
        .presentationDetents([.large])
        .presentationBackground(.red)
        .presentationCornerRadius(32)
        .presentationDragIndicator(.visible)
        .onAppear {
            updateDistance()
        }
    }
    
    private func updateDistance() {
        guard let userLocation = locationManager.location else { return }
        let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let distanceInMeters = userLocation.distance(from: placeLocation)
        let distanceInKilometers = distanceInMeters / 1000
        distance = String(format: "%.2f km away", distanceInKilometers)
    }
    
    private func openInMaps(coordinate: CLLocationCoordinate2D, name: String) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func sharePlace(_ place: Place) {
        let coordinates = "\(place.coordinate.latitude),\(place.coordinate.longitude)"
        let mapsURL = "http://maps.apple.com/?q=\(place.name)&ll=\(coordinates)"
        let shareText = """
        Check out \(place.name)!
        \(place.text)
        
        📍 Location: \(mapsURL)
        """
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityController, animated: true)
        }
    }
}

// Location Manager to get user's current location
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

// Helper Views for PlaceDetailSheet
private struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct ActionButton: View {
    let icon: String
    let text: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(text)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.1)
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .tint(.primary)
    }
}

// New helper view for main content
private struct PlaceDetailContent: View {
    let place: Place
    let isLastPlace: Bool
    let nextPlace: Place?
    let goToNext: () -> Void
    let showSheet: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if !isLastPlace, let next = nextPlace {
                NextStopButton(
                    name:next.name,
                    coordinate: next.coordinate,
                    description: next.text,
                    distance: 1000,
                    pitch: next.isLandmark ? 65 : 0,
                    heading: 0,
                    arrival: next.arrival, // Example heading
                    arrivalHour: next.arrivalHour,
                    city: next.city,
                    type: next.type,
                    address: next.address,
                    reason: next.reason,
                    website: next.website,
                    isLandmark: next.isLandmark
                ) {
                    // Move to the next landmark
                    goToNext()
                }
            }
            
            Text(place.name)
                .font(.system(size: 34, weight: .semibold))
                .fontDesign(.serif)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .transition(.opacity)
            
            Text(place.text)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .transition(.opacity)
            
            PillShapedIconTextButton(
                text: "Explore",
                sfSymbol: "safari.fill",
                action: showSheet
            )
        }
    }
}

struct PlaceDetailScreen: View {
    @Environment(\.presentationMode)
    var presentationMode
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
        @State private var lookaroundScene: MKLookAroundScene?
        @State private var showLookAround = false
        @State private var selectedPlace: Place?
        @State private var isTransitioning = false
        @State private var transitionDistance: CLLocationDistance = 0
        @State private var isMapPreloaded = false
        @State private var route : MKRoute?
    

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
                        ForEach(places, id: \.id) { place in
                            if !place.isLandmark {
                                Marker(place.name, coordinate: place.coordinate)
                                    .tint(.red)
                            }
                        }
                        // Draw the route if available
                        if let route = route {
                            MapPolyline(route.polyline)
                                .stroke(Color.red, lineWidth: 5)
                        }
                    }
                        .onAppear {
                            if (!isMapPreloaded) {
                                // Use a higher pitch for landmarks, lower pitch for non-landmarks
                                let initialPitch: CLLocationDegrees = currentPlace.isLandmark ? 65 : 0
                                
                                position = .camera(
                                    MapCamera(
                                        centerCoordinate: currentPlace.coordinate,
                                        distance: distance,
                                        heading: heading,
                                        pitch: initialPitch
                                    )
                                )
                                updateMapCamera(for: currentPlace)
                                isMapPreloaded = true
                            }
                            calculateRoute()
                        }
                        .task {
                            await fetchLookaroundPreview()
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
                            if currentPlaceIndex < places.count - 1 {
                                // Show the NextStopButton if there's a next landmark
                                NextStopButton(
                                    name: places[currentPlaceIndex + 1].name,
                                    coordinate: places[currentPlaceIndex + 1].coordinate,
                                    description: places[currentPlaceIndex + 1].text,
                                    distance: 1000,
                                    pitch: places[currentPlaceIndex].isLandmark ? 65 : 0, // Example distance
                                    heading: 0,
                                    arrival: places[currentPlaceIndex + 1].arrival, // Example heading
                                    arrivalHour: places[currentPlaceIndex + 1].arrivalHour,
                                    city: places[currentPlaceIndex + 1].city,
                                    type: places[currentPlaceIndex + 1].type,
                                    address: places[currentPlaceIndex + 1].address,
                                    reason: places[currentPlaceIndex + 1].reason,
                                    website: places[currentPlaceIndex + 1].website,
                                    isLandmark: places[currentPlaceIndex + 1].isLandmark
                                ) {
                                    // Move to the next landmark
                                    goToNextLandmark()
                                }
                            }

                            Text(currentPlace.name)
                                .font(.system(size: 34, weight: .semibold))
                                .fontDesign(.serif)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: currentPlaceIndex)

                            Text(currentPlace.text)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: currentPlaceIndex)
                            
                            PillShapedIconTextButton(
                                text: "Explore",
                                sfSymbol: "safari.fill"
                            ) {
                                // Your action here, e.g., toggling a sheet
                                showUnlockSheet.toggle()
                            }
                            .sheet(isPresented: $showUnlockSheet) {
                                PlaceDetailSheet(
                                    place: currentPlace,
                                    lookaroundScene: lookaroundScene,
                                    dismissAction: { showUnlockSheet.toggle() }
                                )
                                .presentationBackground(.regularMaterial)
                            }
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
                .sheet(isPresented: $showUnlockSheet) {
                    PlaceDetailSheet(
                        place: currentPlace,
                        lookaroundScene: lookaroundScene,
                        dismissAction: { showUnlockSheet.toggle() }
                    )
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
    
    private func preloadMap(for place: Place) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        options.size = CGSize(width: 1, height: 1) // Minimal size to preload tiles
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { _, _ in
            // Map tiles are now cached
            isMapPreloaded = true
        }
    }
    
    private func updateMapCamera(for landmark: Place) {
        // Cancel any existing timer
        rotationTimer?.invalidate()
        
        if isTransitioning {
            // Show aerial view during transition
            withAnimation(.easeInOut(duration: 2.0)) {
                position = .camera(
                    MapCamera(
                        centerCoordinate: midpointBetween(
                            currentPlace.coordinate,
                            places[currentPlaceIndex - 1].coordinate
                        ),
                        distance: max(transitionDistance * 1.5, 2000), // Ensure we're high enough
                        heading: heading,
                        pitch: 0 // Aerial view
                    )
                )
            }
            
            // After showing distance, animate to destination
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 2.0)) {
                    position = .camera(
                        MapCamera(
                            centerCoordinate: landmark.coordinate,
                            distance: distance,
                            heading: heading,
                            pitch: landmark.isLandmark ? 65 : 0
                        )
                    )
                }
                isTransitioning = false
                startRotation()
            }
        } else {
            // Normal camera update without transition
            withAnimation(.easeInOut(duration: 2.0)) {
                position = .camera(
                    MapCamera(
                        centerCoordinate: landmark.coordinate,
                        distance: distance,
                        heading: heading,
                        pitch: landmark.isLandmark ? 65 : 0
                    )
                )
            }
            startRotation()
        }
    }
    
    private func startRotation() {
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
                        pitch: currentPlace.isLandmark ? 65 : 0
                    )
                )
            }
        }
    }
    
    private func goToNextLandmark() {
        if currentPlaceIndex < places.count - 1 {
            isTransitioning = true
            transitionDistance = calculateDistance(
                from: currentPlace.coordinate,
                to: places[currentPlaceIndex + 1].coordinate
            )
            
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPlaceIndex += 1
            }
            updateMapCamera(for: currentPlace)
            calculateRoute()
            Task {
                await fetchLookaroundPreview()
            }
        }
    }
    
    private func calculateRoute() {
        guard currentPlaceIndex < places.count - 1 else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentPlace.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: places[currentPlaceIndex + 1].coordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.route = route
        }
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    private func midpointBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat1 = coord1.latitude * .pi / 180
        let lon1 = coord1.longitude * .pi / 180
        let lat2 = coord2.latitude * .pi / 180
        let lon2 = coord2.longitude * .pi / 180
        
        let bx = cos(lat2) * cos(lon2 - lon1)
        let by = cos(lat2) * sin(lon2 - lon1)
        
        let lat3 = atan2(sin(lat1) + sin(lat2),
                        sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by))
        let lon3 = lon1 + atan2(by, cos(lat1) + bx)
        
        return CLLocationCoordinate2D(
            latitude: lat3 * 180 / .pi,
            longitude: lon3 * 180 / .pi
        )
    }
    
    func fetchLookaroundPreview() async {
        lookaroundScene = nil
        let lookaroundRequest = MKLookAroundSceneRequest(coordinate: currentPlace.coordinate)
        lookaroundScene = try? await lookaroundRequest.scene
    }
}

#Preview {
    /*let samplePlaces = [
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
            title: "Belém Tower",
            description: "A 16th-century fortified tower located in Lisbon, Portugal. Built during the Age of Discoveries, this UNESCO World Heritage site served as both a fortress and a ceremonial gateway to Lisbon.",
            isLandmark: true,
            arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
            arrivalHour: "14:00",
            city: "Lisbon",
            type: "Landmark",
            address: "Av. Brasília, 1400-038 Lisboa, Portugal",
            duration: "1 hour",
            reason: "Iconic landmark with historical significance"
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6970, longitude: -9.2033),
            title: "Pastéis de Belém",
            description: "The original home of Portugal's famous pastéis de nata, this historic pastry shop has been serving their secret-recipe custard tarts since 1837. Located near Jerónimos Monastery, it's a must-visit culinary destination.",
            isLandmark: false,
            arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
            arrivalHour: "15:00",
            city: "Lisbon",
            type: "Restaurant",
            address: "R. de Belém 84-92, 1300-085 Lisboa, Portugal",
            duration: "1 hour",
            reason: "Famous for its delicious pastries"
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.7139, longitude: -9.1334),
            title: "São Jorge Castle",
            description: "Perched atop Lisbon's highest hill, this medieval castle dates back to the 11th century. It offers panoramic views of the city and stands as a testament to Portugal's rich history of Moorish and Christian rule.",
            isLandmark: true,
            arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
            arrivalHour: "17:00",
            city: "Lisbon",
            type: "Landmark",
            address: "R. de Santa Cruz do Castelo, 1100-129 Lisboa, Portugal",
            duration: "2 hours",
            reason: "Iconic landmark with breathtaking views"
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6977, longitude: -9.2063),
            title: "Jerónimos Monastery",
            description: "A magnificent example of Manueline architecture, this monastery was built in the 16th century. UNESCO-listed, it commemorates Vasco da Gama's voyage and represents the wealth of Portuguese discovery era.",
            isLandmark: true,
            arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
            arrivalHour: "19:00",
            city: "Lisbon",
            type: "Landmark",
            address: "Praça do Império 1400-206 Lisboa, Portugal",
            duration: "1.5 hours",
            reason: "UNESCO World Heritage site with historical significance"
        )
    ]
    PlaceDetailScreen(places: samplePlaces, title: "Lisbon Highlights", placeIndex: 0)*/
}
