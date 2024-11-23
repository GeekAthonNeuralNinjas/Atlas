//
//  NetworkManager.swift
//  Atlas
//
//  Created by Miguel Susano on 23/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//
import Foundation
import MapKit

struct NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchPlaces(completion: @escaping (Result<[Place], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:5000/sample") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(PlaceResponse.self, from: data)
                let places = decodedResponse.places.map { placeData in
                    Place(
                        coordinate: CLLocationCoordinate2D(
                            latitude: Double(placeData.coordinates[0])!,
                            longitude: Double(placeData.coordinates[1])!
                        ),
                        title: placeData.title,
                        description: placeData.description,
                        isLandmark: placeData.isLandmark
                    )
                }
                completion(.success(places))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct PlaceResponse: Decodable {
    let places: [PlaceData]
}

struct PlaceData: Decodable {
    let city: String
    let coordinates: [String]
    let description: String
    let isLandmark: Bool
    let title: String
}
