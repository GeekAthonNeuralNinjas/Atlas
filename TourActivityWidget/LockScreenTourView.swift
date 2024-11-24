//
//  LockScreenTourView.swift
//  Atlas
//
//  Created by João Franco on 24/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//


import WidgetKit
import SwiftUI
import ActivityKit

// Helper view for the Lock Screen version
struct LockScreenTourView: View {
    let context: ActivityViewContext<TourAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.body)
                Text(context.attributes.tourName)
                    .font(.headline)
                    .lineLimit(1)
            }
            
            Text(context.state.currentPlace)
                .font(.subheadline)
                .lineLimit(1)
            
            if let next = context.state.nextPlace {
                Text("Next: \(next)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Gauge(value: context.state.progress) {
                EmptyView()
            }
            .gaugeStyle(.linearCapacity)
            .tint(.blue)
        }
        .padding()
    }
}

// Main Widget struct
struct TourActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TourAttributes.self) { context in
            LockScreenTourView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.state.currentPlace)
                            .font(.headline)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "map.fill")
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Label {
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "percent")
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.tourName)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading) {
                        if let next = context.state.nextPlace {
                            Label {
                                Text("Next: \(next)")
                                    .lineLimit(1)
                            } icon: {
                                Image(systemName: "arrow.right")
                            }
                            .font(.caption)
                        }
                        
                        Gauge(value: context.state.progress) {
                            EmptyView()
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(.blue)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Label {
                    Text(context.state.currentPlace)
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "map.fill")
                }
                .font(.caption2)
            } compactTrailing: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "map.fill")
            }
        }
    }
}

// Preview provider for the widget
#Preview(as: .dynamicIsland(.expanded)) {
    TourActivityWidget()
} timeline: {
    TourAttributes(
        tourName: "Lisbon Tour",
        totalPlaces: 5
    )
}

#Preview(as: .dynamicIsland(.compact)) {
    TourActivityWidget()
} timeline: {
    TourAttributes(
        tourName: "Lisbon Tour",
        totalPlaces: 5
    )
}

#Preview(as: .dynamicIsland(.minimal)) {
    TourActivityWidget()
} timeline: {
    TourAttributes(
        tourName: "Lisbon Tour",
        totalPlaces: 5
    )
}
