//
//  Place.swift
//  Atlas
//
//  Created by João Franco on 22/11/2024.
//

import Foundation
import SwiftData
import MapKit

@Model
final class Place {
    var id: String
    var latitude: Double
    var longitude: Double
    var title: String
    var text: String
    var isLandmark: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: String = UUID().uuidString,
         coordinate: CLLocationCoordinate2D,
         title: String,
         description: String,
         isLandmark: Bool) {
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.title = title
        self.text = description
        self.isLandmark = isLandmark
    }
}
