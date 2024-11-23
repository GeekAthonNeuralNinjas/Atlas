import SwiftUI
import MapKit

struct Home: View {
    @State private var landmarks: [Place] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading places...")
                    .navigationTitle("Landmarks")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            headerView
                            ForEach(landmarks.indices, id: \.self) { index in
                                NavigationLink(
                                    destination: LandmarkScreen(
                                        landmarks: landmarks,
                                        title: "Landmarks",
                                        currentLandmarkIndex: index
                                    )
                                ) {
                                    placeCard(place: landmarks[index])
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                }
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
                    landmarks = fetchedPlaces
                case .failure(let error):
                    errorMessage = "Failed to load places: \(error.localizedDescription)"
                }
            }
        }
    }
}