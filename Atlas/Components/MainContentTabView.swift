
import SwiftUI

struct MainContentTabView: View {
    @Binding var currentStep: Int
    @Binding var startDate: Date
    @Binding var days: Int
    @Binding var selectedCity: City?
    @Binding var selectedStyle: VacationStyle?
    @Binding var selectedCityIndex: Int
    @Binding var selectedStyleIndex: Int
    let predefinedCities: [City]
    let vacationStyles: [VacationStyle]
    
    var body: some View {
        TabView(selection: $currentStep) {
            dateSelectionView
                .tag(1)
            durationSelectionView
                .tag(2)
            locationSelectionView
                .tag(3)
            styleSelectionView
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var dateSelectionView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Plan Your Trip")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("When to go?")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        DatePicker("Start Date",
                                   selection: $startDate,
                                   in: Date()...,
                                   displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }
    
    private var durationSelectionView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Duration")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("How many days?")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            Button(action: { if days > 1 { withAnimation(.spring()) { days -= 1 } } }) {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 44))
                                    .foregroundStyle(days > 1 ? Color.primary : .secondary.opacity(0.3))
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
                                    .foregroundStyle(days < 15 ? Color.primary : .secondary.opacity(0.3))
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
                                .frame(width: geometry.size.width - 32, height: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(city.name)
                                    .font(.title3.bold())
                                Text(city.country)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 380, alignment: .leading)
                            .padding(16)
                            .background {
                                Rectangle()
                                    .fill(.linearGradient(
                                        colors: [.black.opacity(0.7), .clear],
                                        startPoint: .bottom,
                                        endPoint: .top))
                            }
                        }
                        .frame(width: geometry.size.width - 32, height: 380)
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
