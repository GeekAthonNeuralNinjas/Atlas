//
//  AtlasApp.swift
//  Atlas
//
//  Created by João Franco on 22/11/2024.
//

import SwiftUI
import SwiftData

@main
struct AtlasApp: App {
    let container: ModelContainer
    init() {
            do {
                container = try ModelContainer(for: Tour.self, Place.self)
            } catch {
                fatalError("Failed to initialize ModelContainer")
            }
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
