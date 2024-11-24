//
//  TourActivityWidgetLiveActivity.swift
//  TourActivityWidget
//
//  Created by João Franco on 24/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TourActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TourActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TourActivityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TourActivityWidgetAttributes {
    fileprivate static var preview: TourActivityWidgetAttributes {
        TourActivityWidgetAttributes(name: "World")
    }
}

extension TourActivityWidgetAttributes.ContentState {
    fileprivate static var smiley: TourActivityWidgetAttributes.ContentState {
        TourActivityWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TourActivityWidgetAttributes.ContentState {
         TourActivityWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TourActivityWidgetAttributes.preview) {
   TourActivityWidgetLiveActivity()
} contentStates: {
    TourActivityWidgetAttributes.ContentState.smiley
    TourActivityWidgetAttributes.ContentState.starEyes
}
