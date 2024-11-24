import SwiftUI
import SwiftData
import MapKit
import Combine

struct ToursListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tours: [Tour]
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var currentLandmarkIndex = 0
    @State private var timer: AnyCancellable?
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var selectedPlace: Place?
    
    var currentTourLandmarks: [Place] {
        tours.first?.places.filter { $0.isLandmark } ?? []
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(colors: [Color(.systemBackground).opacity(0.8), Color(.systemBackground)],
                             startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading trips...")
                        .navigationTitle("Trips")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .navigationTitle("Trips")
                } else if tours.isEmpty {
                    // Empty state when there are no tours
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        Text("No Tours Available")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                        
                        Text("Start by creating a new tour using the '+' button above.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .navigationTitle("Trips")
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            LazyVStack(spacing: 16) {
                                ForEach(tours) { tour in
                                    NavigationLink(
                                        destination: PlacesListScreen(title: tour.name, tour: tour)
                                    ) {
                                        tourCard(tour: tour)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                        }
                    }
                    .navigationTitle("Trips")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTourScreen()) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .onAppear {
            if tours.isEmpty {
                addSampleData()
            }
            isLoading = false
            startTimer()
        }
        .onDisappear {
            timer?.cancel()
        }
    }
    
    private func tourCard(tour: Tour) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "map")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tour.name)
                    .font(.headline)
                Text("\(tour.places.filter { $0.isLandmark }.count) landmarks")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func addSampleData() {
        // Sample data for testing (can be uncommented for testing)
        /*let samplePlaces = [
            Place(
                coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
                title: "Belém Tower",
                description: "A 16th-century fortified tower located in Lisbon, Portugal.",
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
                description: "The original home of Portugal's famous pastéis de nata.",
                isLandmark: false,
                arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
                arrivalHour: "15:00",
                city: "Lisbon",
                type: "Restaurant",
                address: "R. de Belém 84-92, 1300-085 Lisboa, Portugal",
                duration: "1 hour",
                reason: "Famous for its delicious pastries"
            )
        ]
        
        let tour = Tour(name: "Lisbon Highlights", text: "A tour of Lisbon's most iconic landmarks and restaurants.")
        tour.places = samplePlaces
        modelContext.insert(tour)
        
        try? modelContext.save()*/
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateMapRegion()
            }
    }
    
    private func updateMapRegion() {
        guard !currentTourLandmarks.isEmpty else { return }
        currentLandmarkIndex = (currentLandmarkIndex + 1) % currentTourLandmarks.count
        let landmark = currentTourLandmarks[currentLandmarkIndex]
        
        withAnimation {
            mapCameraPosition = .region(MKCoordinateRegion(
                center: landmark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
}

// Add this extension for the fade transition
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }
}

#Preview {
    ToursListScreen()
}
