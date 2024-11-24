import SwiftUI
import MapKit
import CoreLocation

struct NextStopButton: View {
    // MARK: - Properties
    var name: String
    var coordinate: CLLocationCoordinate2D
    var description: String
    var distance: CLLocationDistance
    var pitch: CGFloat
    var heading: CLLocationDirection
    var arrival: Date
    var arrivalHour: String
    var city: String
    var type: String
    var address: String?
    var reason: String
    var website: String?
    var isLandmark: Bool
    
    // A callback closure to handle actions like updating state or camera position
    var onTap: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            // Action to perform when button is tapped
            let nextStop = Place(
                coordinate: coordinate,
                name: name,
                description: description,
                arrival: arrival,
                arrivalHour: arrivalHour,
                city: city,
                type: type,
                address: address,
                reason: reason,
                website: website,
                isLandmark: isLandmark
            )
            
            withAnimation(.easeInOut(duration: 3)) {
                let camera = MapCamera(
                    centerCoordinate: nextStop.coordinate,
                    distance: distance,
                    heading: pitch,
                    pitch: heading
                )
                
                // Example UIView animation (assuming UIKit is integrated with SwiftUI)
                UIView.animate(withDuration: 2.0) {
                    // Position update logic goes here, if necessary
                    onTap?()
                }
            }
        }) {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 12))
                Text("Next Stop: \(name)")
                    .font(.system(size: 14))
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.2))
            .background(Material.ultraThin)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            )
            .fontDesign(.default)
        }
    }
}

// MARK: - Preview
#Preview {
    NextStopButton(
        name: "Arc de Triomphe",
        coordinate: CLLocationCoordinate2D(latitude: 48.8738, longitude: 2.2950),
        description: "The Arc de Triomphe is one of the most famous monuments in Paris, standing at the western end of the Champs-Élysées. It honors those who fought and died for France in the French Revolutionary and Napoleonic Wars.",
        distance: 1000, // Example distance
        pitch: 65, // Example pitch
        heading: 0, // Example heading
        arrival: DateFormatter().date(from: "25/11/2024") ?? Date(),
        arrivalHour: "14:00",
        city: "Paris",
        type: "Landmark",
        address: "Place Charles de Gaulle, 75008 Paris, France",
        reason: "Iconic landmark with historical significance",
        website: "https://example.com/arc-de-triomphe",
        isLandmark: false
    ) {
        // Example onTap action
        print("Next Stop tapped!")
    }
}
