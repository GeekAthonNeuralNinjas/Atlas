//
//  PillShapedIconTextButton.swift
//  Atlas
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI

struct PillShapedIconTextButton: View {
    var text: String
    var sfSymbol: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: sfSymbol)
                    .font(.system(size: 12))
                Text(text)
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
