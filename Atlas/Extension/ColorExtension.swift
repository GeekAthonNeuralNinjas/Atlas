//
//  ColorExtension.swift
//  SATA
//
//  Created by João Franco on 23/11/2024.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        let r, g, b: Double

        // Remove the leading # if it exists
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }

        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double(hexNumber & 0x0000ff) / 255

            self.init(red: r, green: g, blue: b)
        } else {
            self.init(red: 0, green: 0, blue: 0) // Default to black if there's an issue
        }
    }
}
