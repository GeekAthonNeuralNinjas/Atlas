//
//  TransparentNavigationBarModifier.swift
//  Atlas
//
//  Created by João Franco on 22/11/2024.
//


import SwiftUI
import UIKit

struct TransparentNavigationBarModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func transparentNavigationBar() -> some View {
        self.modifier(TransparentNavigationBarModifier())
    }
}