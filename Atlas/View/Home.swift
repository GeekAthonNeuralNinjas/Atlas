//
//  Home.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import MapKit
import SwiftUI

struct Home: View {
    public var landmarks = [
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6916, longitude: -9.2157),
            title: "Belém Tower",
            description: "A 16th-century fortified tower located in Lisbon, Portugal. Built during the Age of Discoveries, this UNESCO World Heritage site served as both a fortress and a ceremonial gateway to Lisbon.",
            isLandmark: true
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.7139, longitude: -9.1334),
            title: "São Jorge Castle",
            description: "Perched atop Lisbon's highest hill, this medieval castle dates back to the 11th century. It offers panoramic views of the city and stands as a testament to Portugal's rich history of Moorish and Christian rule.",
            isLandmark: true
        ),
        Place(
            coordinate: CLLocationCoordinate2D(latitude: 38.6977, longitude: -9.2063),
            title: "Jerónimos Monastery",
            description: "A magnificent example of Manueline architecture, this monastery was built in the 16th century. UNESCO-listed, it commemorates Vasco da Gama's voyage and represents the wealth of Portuguese discovery era.",
            isLandmark: true
        )
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            headerView
                            ForEach(0..<10) { _ in
                                let destinationView = LandmarkScreen(
                                    landmarks: landmarks,
                                    title: "Landmarks"
                                )
                                .toolbar(.visible)
                                
                                NavigationLink(destination: destinationView) {
                                    tripCard
                                        .toolbarBackground(.hidden, for: .navigationBar)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .ignoresSafeArea()
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
    }
}
