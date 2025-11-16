//
//  prayer_widgetExtensionLiveActivity.swift
//  prayer_widgetExtension
//
//  Created by Hawazen Mahmood on 11/15/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct prayer_widgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct prayer_widgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: prayer_widgetExtensionAttributes.self) { context in
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

extension prayer_widgetExtensionAttributes {
    fileprivate static var preview: prayer_widgetExtensionAttributes {
        prayer_widgetExtensionAttributes(name: "World")
    }
}

extension prayer_widgetExtensionAttributes.ContentState {
    fileprivate static var smiley: prayer_widgetExtensionAttributes.ContentState {
        prayer_widgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: prayer_widgetExtensionAttributes.ContentState {
         prayer_widgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: prayer_widgetExtensionAttributes.preview) {
   prayer_widgetExtensionLiveActivity()
} contentStates: {
    prayer_widgetExtensionAttributes.ContentState.smiley
    prayer_widgetExtensionAttributes.ContentState.starEyes
}
