import SwiftUI
import MapKit

struct PlacesListScreen: View {
    @State public var title: String
    @State private var places: [Place] = []
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
                    VStack(alignment: .leading, spacing: 10) { // Adjust the spacing here if needed
                        ForEach(places.indices, id: \.self) { index in
                            NavigationLink(
                                destination:
                                    PlaceDetailScreen(
                                        places: places,
                                        title: "Places to See",
                                        placeIndex: index
                                    )
                                )
                            {
                                placeCard(place: places[index])
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal) // Horizontal padding only
                }
                .navigationTitle(title)
            }
        }
        .onAppear {
            fetchPlaces()
        }
    }

    private func fetchPlaces() {
        NetworkManager.shared.fetchPlaces { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedPlaces):
                    places = fetchedPlaces
                case .failure(let error):
                    errorMessage = "Failed to load places: \(error.localizedDescription)"
                }
            }
        }
    }
}
