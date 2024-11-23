//
//  TripCard.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI
func tripCard(place: Place) -> some View {
    VStack(alignment: .leading) {
        HStack {
            Image(systemName: place.isLandmark ? "star.circle.fill" : "mappin.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(place.isLandmark ? .yellow : .blue)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(place.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(place.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
    }
}
