import SwiftUI
import SwiftData
import MapKit

struct ToursListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tours: [Tour]
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading trips...")
                        .navigationTitle("Trips")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .navigationTitle("Trips")
                } else {
                    GeometryReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(tours) { tour in
                                    NavigationLink(
                                        destination: PlacesListScreen(title: tour.name, tour: tour)
                                    ) {
                                        tourCard(tour: tour)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                    .navigationTitle("Trips")
                }
            }
        }
        .onAppear {
            if tours.isEmpty {
                addSampleData()
            }
            isLoading = false
        }
    }
    
    private func tourCard(tour: Tour) -> some View {
        VStack(alignment: .leading) {
            Text(tour.name)
                .font(.headline)
            Text("\(tour.places.count) places")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func addSampleData() {
        let samplePlaces = [
            Place(
                coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
                title: "Belém Tower",
                description: "A 19th-century fortified tower located in Lisbon, Portugal.",
                isLandmark: true
            ),
            Place(
                coordinate: CLLocationCoordinate2D(latitude: 38.6970, longitude: -9.2033),
                title: "Pastéis de Belém",
                description: "The not so original home of Portugal's famous pastéis de nata.",
                isLandmark: false
            )
        ]
        
        let tour = Tour(name: "Lisbon also Highlights")
        tour.places = samplePlaces
        modelContext.insert(tour)
        
        try? modelContext.save()
    }
}
