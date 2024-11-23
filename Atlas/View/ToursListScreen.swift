import SwiftUI
import MapKit

struct ToursListScreen: View {
    @State private var tours: [Tour] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading trips...")
                        .navigationTitle("Trips")  // Title when loading
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .navigationTitle("Trips")  // Title when there is an error
                } else {
                    GeometryReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(tours.indices, id: \.self) { index in
                                    NavigationLink(
                                        destination: PlacesListScreen(title: tours[index].name)
                                    ) {
                                        tourCard(tour: tours[index])
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                    .navigationTitle("Trips")  // Title when tours are loaded
                }
            }
        }
        .onAppear {
            fetchTours()
        }
    }

    private func fetchTours() {
        DispatchQueue.main.async {
            tours.append(sampleTour)
            isLoading = false
        }
    }
}

#Preview {
    ToursListScreen()
}
