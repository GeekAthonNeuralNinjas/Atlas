//
//  TripCard.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI

var tripCard: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("trip")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                VStack(alignment: .leading) {
                    Text("Trip to Paris")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Paris, France")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
