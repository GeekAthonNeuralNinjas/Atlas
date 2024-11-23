import SwiftUI
import MapKit

struct Tours: View {
    @State private var tours: [Tour] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading trips...")
                    .navigationTitle("Trips")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            headerView
                            ForEach(tours.indices, id: \.self) { index in
                                NavigationLink(
                                    destination: Home(
                                    )
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
            }
        }
        .onAppear {
            fetchTours()
        }
    }

    private func fetchTours() {
        DispatchQueue.main.async{
            
            tours.append(sampleTour)
            isLoading = false

        }
    }
}
