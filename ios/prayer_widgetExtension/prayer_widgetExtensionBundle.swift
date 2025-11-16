//
//  prayer_widgetExtensionBundle.swift
//  prayer_widgetExtension
//
//  Created by Hawazen Mahmood on 11/15/25.
//

import WidgetKit
import SwiftUI

@main
struct prayer_widgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        prayer_widget()
        prayer_widgetExtensionControl()
        prayer_widgetExtensionLiveActivity()
    }
}
