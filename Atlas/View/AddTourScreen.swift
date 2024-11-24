import SwiftUI
import MapKit
import SwiftData

struct TourAPIResponse: Decodable {
    let description: String
    let name: String
    let places: [PlaceAPIData]
}

struct PlaceAPIData: Decodable {
    let arrival: String
    let arrival_hour: String
    let city: String
    let coordinates: Coordinates
    let description: String
    let name: String
    let type: String
    let adress: String?
    let reason: String
    let website: String?
    let isLandmark: Bool
}

struct Coordinates: Decodable {
    let lat: Double
    let log: Double
}

struct TourPrompt: Encodable {
    let city: String
    let start_date: String
    let duration: Int
    let flavour: String
}

class TourAPIService {
    static let shared = TourAPIService()
    private init() {}
    
    func generateTour(prompt: TourPrompt) async throws -> TourAPIResponse {
        var components = URLComponents(string: "https://atlas-api-service.xb8vmgez1emgp.us-west-2.cs.amazonlightsail.com/plan")!
        components.queryItems = [
            URLQueryItem(name: "city", value: prompt.city),
            URLQueryItem(name: "start_date", value: prompt.start_date),
            URLQueryItem(name: "duration", value: String(prompt.duration)),
            URLQueryItem(name: "flavour", value: prompt.flavour)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // Print the complete URL
        print("Making request to URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response:")
            print(jsonString)
        }
        return try JSONDecoder().decode(TourAPIResponse.self, from: data)
    }
}

struct AddTourScreen: View {
    enum AtlasState {
        case none
        case thinking
    }
    
    @State private var days = 1
    @State private var currentStep = 1
    @State private var selectedCity: City?
    @State private var selectedStyle: VacationStyle?
    @State private var selectedCityIndex = 0
    @State private var selectedStyleIndex = 0
    @State private var startDate = Date()
    
    @State private var navigateToPlaceDetail = false
    @State private var createdTour: Tour?
    @State private var state: AtlasState = .none
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(\.modelContext) private var modelContext
    
    let predefinedCities = [
        City(name: "Lisbon", country: "Portugal", imageName: "lisbon"),
        City(name: "Leiria", country: "Portugal", imageName: "leiria"),
        City(name: "Madrid", country: "Spain", imageName: "madrid"),
        City(name: "Barcelona", country: "Spain", imageName: "barcelona"),
        City(name: "New York", country: "USA", imageName: "new_york"),
        City(name: "Paris", country: "France", imageName: "paris")
    ]
    
    let vacationStyles = [
        VacationStyle(name: "Relax", description: "Peaceful and relaxing experience", imageName: "relax",
                      colors: [.blue, .cyan]),
        VacationStyle(name: "Culture", description: "Museums, history and local traditions", imageName: "culture",
                      colors: [.purple, .indigo]),
        VacationStyle(name: "Gastronomical", description: "Local cuisine and food experiences", imageName: "food",
                      colors: [.orange, .red]),
        VacationStyle(name: "Radical", description: "Adventure and extreme sports", imageName: "radical",
                      colors: [.green, .mint]),
        VacationStyle(name: "Fun", description: "Entertainment and nightlife", imageName: "fun",
                      colors: [.pink, .purple])
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                StepIndicator(currentStep: currentStep)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                MainContentTabView(
                    currentStep: $currentStep,
                    startDate: $startDate,
                    days: $days,
                    selectedCity: $selectedCity,
                    selectedStyle: $selectedStyle,
                    selectedCityIndex: $selectedCityIndex,
                    selectedStyleIndex: $selectedStyleIndex,
                    predefinedCities: predefinedCities,
                    vacationStyles: vacationStyles
                )
                
                Button(action: handleFinishButton) {
                    Text(currentStep < 4 ? "Next" : "Finish")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(colors: [.primary.opacity(0.05), .clear],
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .navigationDestination(isPresented: $navigateToPlaceDetail) {
                if let tour = createdTour, let firstPlace = tour.places.first {
                    PlaceDetailScreen(places: tour.places, title: tour.name, placeIndex: 0)
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleFinishButton() {
        if currentStep < 4 {
            withAnimation(.spring()) {
                currentStep += 1
            }
        } else {
            handleSendButton()
        }
    }
    
    private func handleSendButton() {
        Task {
            do {
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .thinking
                }
                
                // Create the TourPrompt
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                let formattedStartDate = dateFormatter.string(from: startDate)
                
                let prompt = TourPrompt(
                    city: selectedCity?.name ?? "",
                    start_date: formattedStartDate,
                    duration: days,
                    flavour: selectedStyle?.name ?? ""
                )
                
                // Print the prompt structure
                print("Prompt: \(prompt)")
                
                // Make the HTTP request
                let response = try await TourAPIService.shared.generateTour(prompt: prompt)
                let tour = createTour(from: response)
                createdTour = tour
                
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                    navigateToPlaceDetail = true
                }
            } catch {
                showError = true
                errorMessage = error.localizedDescription
                
                withAnimation(.easeInOut(duration: 0.9)) {
                    state = .none
                }
            }
        }
    }
    
    private func createTour(from response: TourAPIResponse) -> Tour {
            let tour = Tour(
                name: response.name,
                text: response.description
            )
            
            let places = response.places.map { placeData in
                let coordinate = CLLocationCoordinate2D(
                    latitude: placeData.coordinates.lat,
                    longitude: placeData.coordinates.log
                )
                
                // Convert arrival string to Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                let arrivalDate = dateFormatter.date(from: placeData.arrival) ?? Date()
                
                return Place(
                    coordinate: coordinate,
                    name: placeData.name,
                    description: placeData.description,
                    arrival: arrivalDate,
                    arrivalHour: placeData.arrival_hour,
                    city: placeData.city,
                    type: placeData.type,
                    address: placeData.adress,
                    reason: placeData.reason,
                    website: placeData.website,
                    isLandmark: placeData.isLandmark
                )
            }
            
            tour.places = places
            modelContext.insert(tour)
            try? modelContext.save()
            return tour
        }



}

#Preview {
    /*AddTourScreen(
        predefinedCities: [
            City(name: "Lisbon", country: "Portugal", imageName: "lisbon"),
            City(name: "Leiria", country: "Portugal", imageName: "leiria"),
            City(name: "Madrid", country: "Spain", imageName: "madrid"),
            City(name: "Barcelona", country: "Spain", imageName: "barcelona"),
            City(name: "New York", country: "USA", imageName: "new_york"),
            City(name: "Paris", country: "France", imageName: "paris")
        ],
        vacationStyles: [
            VacationStyle(name: "Relax", description: "Peaceful and relaxing experience", imageName: "relax",
                          colors: [.blue, .cyan]),
            VacationStyle(name: "Culture", description: "Museums, history and local traditions", imageName: "culture",
                          colors: [.purple, .indigo]),
            VacationStyle(name: "Gastronomical", description: "Local cuisine and food experiences", imageName: "food",
                          colors: [.orange, .red]),
            VacationStyle(name: "Radical", description: "Adventure and extreme sports", imageName: "radical",
                          colors: [.green, .mint]),
            VacationStyle(name: "Fun", description: "Entertainment and nightlife", imageName: "fun",
                          colors: [.pink, .purple])
        ]
    )*/
}
