import SwiftUI
import SwiftData
import MapKit

struct PlacesListScreen: View {
    let title: String
    let tour: Tour
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private var landmarks: [Place] {
        tour.places.filter { $0.isLandmark }
    }
    
    private var nonLandmarks: [Place] {
        tour.places.filter { !$0.isLandmark }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if isLoading {
                ProgressView("Loading places...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) { // Changed spacing from 20 to 0
                        // Header Image with Title
                        ZStack(alignment: .top) {
                            ZStack(alignment: .bottomLeading) {
                                Image("lisbon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 400)
                                    .clipped()
                                
                                VStack {
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(.systemBackground).opacity(0.8), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 100)
                                    .ignoresSafeArea()
                                    Spacer()
                                }
                                
                                VStack {
                                    VariableBlurView(
                                        maxBlurRadius: 10
                                    )
                                    .frame(height: 125)
                                    .ignoresSafeArea()
                                    Spacer()
                                }
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(.systemBackground).opacity(1), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 400)
                                
                                Text(title)
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        
                        //Description
                        Text("Welcome to Lisbon! This tour will take you to some of the most iconic places in the city. From historic landmarks to hidden gems, you'll get to experience the best of Lisbon in just a few days.")
                            .font(.body)
                            .padding(.horizontal)
                            .padding(.vertical, 16)
                            //Add glass border
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                            }
                            .padding(.horizontal)
                        
                        // Landmarks Section
                        if !landmarks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Landmarks:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(landmarks) { place in
                                            NavigationLink(
                                                destination: PlaceDetailScreen(
                                                    places: Array(tour.places),
                                                    title: "Places to See",
                                                    placeIndex: tour.places.firstIndex(of: place) ?? 0
                                                )
                                            ) {
                                                placeCard(place: place)
                                                    .frame(width: 300)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Non-Landmarks Section
                        if !nonLandmarks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Other Places:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(nonLandmarks) { place in
                                            NavigationLink(
                                                destination: PlaceDetailScreen(
                                                    places: Array(tour.places),
                                                    title: "Places to See",
                                                    placeIndex: tour.places.firstIndex(of: place) ?? 0
                                                )
                                            ) {
                                                placeCard(place: place)
                                                    .frame(width: 300)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
        .onAppear {
            isLoading = false
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
            if let firstPlace = tour.places.first {
                let placeIndex = tour.places.firstIndex(of: firstPlace) ?? 0
                NavigationLink(
                destination: PlaceDetailScreen(
                    places: Array(tour.places),
                    title: "Places to See",
                    placeIndex: placeIndex
                )
                ) {
                Image(systemName: "play.fill")
                }
            }
            }
        }
    }
    
    private func placeCard(place: Place) -> some View {
        //Mini Map
        let region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        return VStack(alignment: .leading) {
            //Map
            Map(coordinateRegion: .constant(region))
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .cornerRadius(8)
                .disabled(true)  // Disable map interaction
            VStack(alignment: .leading) {
                Text(place.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(place.text)
                    .font(.subheadline)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            .padding(.vertical,10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}
