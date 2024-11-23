//
//  HeaderView.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI

var headerView: some View {
        HStack {
            Text("My Trips")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
            }) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.primary)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    )
            }
        }
    }
