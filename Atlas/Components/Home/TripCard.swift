//
//  TripCard.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI
func tourCard(tour: Tour) -> some View {
    VStack(alignment: .leading) {
        HStack {
            VStack(alignment: .leading) {
                Text(tour.name)
                    .font(.title3)
                    .fontWeight(.bold)
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
