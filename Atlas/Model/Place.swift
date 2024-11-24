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
final class Place : Identifiable{
    var id: String
    var latitude: Double
    var longitude: Double
    var name: String
    var text: String
    var arrival: Date
    var arrivalHour: String
    var city: String
    var type: String
    var address: String?
    var reason: String
    var website: String?
    var isLandmark: Bool
    
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: String = UUID().uuidString,
         coordinate: CLLocationCoordinate2D,
         name: String,
         description: String,
         arrival: Date,
         arrivalHour: String,
         city: String,
         type: String,
         address: String?,
         reason: String,
         website: String?,
         isLandmark: Bool) {
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.name = name
        self.text = description
        self.arrival = arrival
        self.arrivalHour = arrivalHour
        self.city = city
        self.type = type
        self.address = address
        self.reason = reason
        self.website = website
        self.isLandmark = isLandmark
    }
}
