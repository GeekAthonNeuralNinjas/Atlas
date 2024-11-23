//
//  Trip.swift
//  Atlas
//
//  Created by Miguel Susano on 23/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import Foundation
import MapKit

struct Tour: Identifiable {
    let id = UUID()
    var name: String
    var places: [Place]
}


// Example usage
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

let sampleTour = Tour(name: "Lisbon Highlights", places: samplePlaces)
