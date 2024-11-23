import SwiftUI
import SwiftData
import MapKit

struct PlacesListScreen: View {
    let title: String
    let tour: Tour
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading places...")
                    .navigationTitle(title)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(tour.places.enumerated()), id: \.element.id) { index, place in
                            NavigationLink(
                                destination: PlaceDetailScreen(
                                    places: Array(tour.places),
                                    title: "Places to See",
                                    placeIndex: 0
                                )
                            ) {
                                placeCard(place: place)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle(title)
            }
        }
        .onAppear {
            isLoading = false
        }
    }
    
    private func placeCard(place: Place) -> some View {
        VStack(alignment: .leading) {
            Text(place.title)
                .font(.headline)
            Text(place.text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tour.self, Place.self, configurations: config)
    
    // Add sample data for the preview
    let samplePlaces = [
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
            title: "Belém Tower",
            description: "A 16th-century fortified tower located in Lisbon, Portugal.",
            isLandmark: true
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6970, longitude: -9.2033),
            title: "Pastéis de Belém",
            description: "The original home of Portugal's famous pastéis de nata.",
            isLandmark: false
        )
    ]
    
    let tour = Tour(name: "Lisbon Highlights")
    tour.places = samplePlaces
    container.mainContext.insert(tour)
    
    return ToursListScreen()
        .modelContainer(container)
}
