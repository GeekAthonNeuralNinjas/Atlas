
import Foundation

struct TourAPIResponse: Decodable {
    let places: [PlaceAPIData]
}

struct PlaceAPIData: Decodable {
    let city: String
    let coordinates: [String]
    let description: String
    let isLandmark: Bool
    let reason: String
    let title: String
}

// MARK: - Network Service
class TourAPIService {
    static let shared = TourAPIService()
    private init() {}
    
    func generateTour(prompt: String) async throws -> TourAPIResponse {
        guard let url = URL(string: "https://atlas-api-service.xb8vmgez1emgp.us-west-2.cs.amazonlightsail.com/plan") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(TourAPIResponse.self, from: data)
    }
}