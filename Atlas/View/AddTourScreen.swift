//
//  AddTourScreen.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import SwiftUI

struct AddTourScreen: View {
    @State private var days = 1
    @State private var currentStep = 1
    @State private var selectedCity: City?
    @State private var selectedStyle: VacationStyle?
    @State private var selectedCityIndex = 0
    @State private var selectedStyleIndex = 0
    @State private var startDate = Date()
    
    let predefinedCities = [
        City(name: "Lisbon", country: "Portugal", imageName: "lisbon"),
        City(name: "Leiria", country: "Portugal", imageName: "leiria"),
        City(name: "Madrid", country: "Spain", imageName: "madrid"),
        City(name: "Barcelona", country: "Spain", imageName: "barcelona"),
        City(name: "New York", country: "USA", imageName: "new_york"),
        City(name: "Paris", country: "France", imageName: "paris")
    ]
    
    // Add this after predefinedCities
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
                
                NavigationButtons(currentStep: $currentStep)
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(colors: [.black.opacity(0.05), .clear],
                               startPoint: .top,
                               endPoint: .bottom)
            )
        }
    }
}


#Preview {
    AddTourScreen()
}
