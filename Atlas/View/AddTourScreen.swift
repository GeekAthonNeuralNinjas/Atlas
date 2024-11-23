//
//  AddTourScreen.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import SwiftUI

struct City: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let imageName: String
}

// Add this struct after the City struct
struct VacationStyle: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let colors: [Color]
}

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
                // Step Indicator
                HStack(spacing: 16) {
                    ForEach(1...4, id: \.self) { step in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(step <= currentStep ? Color.accentColor : .secondary.opacity(0.2))
                                .frame(width: 10, height: 10)
                                .overlay {
                                    if step == currentStep {
                                        Circle()
                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 4)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            Text("Step \(step)")
                                .font(.caption2)
                                .foregroundStyle(step <= currentStep ? .primary : .secondary)
                        }
                        if step < 4 {
                            Rectangle()
                                .fill(step < currentStep ? Color.accentColor : .secondary.opacity(0.2))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                TabView(selection: $currentStep) {
                    dateSelectionView.tag(1)
                    durationSelectionView.tag(2)
                    locationSelectionView.tag(3)
                    styleSelectionView.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Navigation
                HStack {
                    Button(action: { withAnimation(.spring()) { currentStep -= 1 } }) {
                        Label("Back", systemImage: "chevron.left")
                            .font(.body.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .opacity(currentStep == 1 ? 0 : 1)
                    .disabled(currentStep == 1)
                    
                    Spacer()
                    
                    Button(action: { withAnimation(.spring()) { currentStep += 1 } }) {
                        Label(currentStep < 4 ? "Next" : "Finish",
                              systemImage: currentStep < 4 ? "chevron.right" : "checkmark")
                        .font(.body.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.accentColor.gradient)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var dateSelectionView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    // Title Section
                    VStack(spacing: 8) {
                        Text("Plan Your Trip")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("When to go?")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Date Selection
                    VStack(spacing: 16) {
                        DatePicker("Start Date",
                                 selection: $startDate,
                                 in: Date()...,
                                 displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private var durationSelectionView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    // Title Section
                    VStack(spacing: 8) {
                        Text("Duration")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("How many days?")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Days Selection
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            Button(action: { if days > 1 { withAnimation(.spring()) { days -= 1 } } }) {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 44))
                                    .foregroundStyle(days > 1 ? .pink : .secondary.opacity(0.3))
                            }
                            .disabled(days <= 1)
                            
                            Text("\(days)")
                                .font(.system(size: 54, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .frame(width: 80)
                                .contentTransition(.numericText(value: Double(days)))
                            
                            Button(action: { if days < 15 { withAnimation(.spring()) { days += 1 } } }) {
                                Image(systemName: "plus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 44))
                                    .foregroundStyle(days < 15 ? .pink : .secondary.opacity(0.3))
                            }
                            .disabled(days >= 15)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Text("Maximum 15 days")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    private var locationSelectionView: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Starting Point")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Choose your city")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                TabView(selection: $selectedCityIndex) {
                    ForEach(Array(predefinedCities.enumerated()), id: \.element.id) { index, city in
                        ZStack(alignment: .bottom) {
                            Image(city.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width - 32, height: 500)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(city.name)
                                    .font(.title3.bold())
                                Text(city.country)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .padding(16)
                            .background {
                                Rectangle()
                                    .fill(.linearGradient(
                                        colors: [.black.opacity(0.7), .clear],
                                        startPoint: .bottom,
                                        endPoint: .top))
                            }
                        }
                        .frame(width: geometry.size.width - 32, height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                        .tag(index)
                    }
                }
                .onChange(of: selectedCityIndex) { newIndex in
                    selectedCity = predefinedCities[newIndex]
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
        }
    }
    
    struct VacationStyleCard: View {
        let style: VacationStyle
        let width: CGFloat
        
        var body: some View {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: style.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        GeometryReader { geo in
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: geo.size.width * 0.8)
                                .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.2)
                                .blur(radius: 30)
                        }
                    }
                    .frame(width: width, height: 500)
                
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(style.name)
                        .font(.title.bold())
                    Text(style.description)
                        .font(.title3)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .frame(width: width, height: 480)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 3)
            }
        }
    }

    private var styleSelectionView: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Vacation Style")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("What's your vibe?")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                TabView(selection: $selectedStyleIndex) {
                    ForEach(Array(vacationStyles.enumerated()), id: \.element.id) { index, style in
                        VacationStyleCard(style: style, width: geometry.size.width - 32)
                            .padding(.horizontal, 16)
                            .tag(index)
                    }
                }
                .onChange(of: selectedStyleIndex) { newIndex in
                    selectedStyle = vacationStyles[newIndex]
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
        }
    }
}

#Preview {
    AddTourScreen()
}
