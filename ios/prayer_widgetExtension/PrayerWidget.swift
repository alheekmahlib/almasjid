//
//  PrayerWidget.swift
//  prayer_widgetExtension
//

import WidgetKit
import SwiftUI

@available(iOS 17.0, *)
struct prayer_widget: Widget {
    // تحذير: لا تُغيّر هذه القيمة! تغييرها يحذف الـ widget من شاشات المستخدمين
    // WARNING: Do NOT change this value! Changing it removes the widget from users' screens
    let kind: String = "prayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            prayer_widgetExtensionEntryView(entry: entry, smallLayout: .standard)
        }
        .configurationDisplayName("أوقات الصلاة")
        .description("ابقَ على اطلاع بمواقيت الصلاة اليومية بدقة مع تحديث تلقائي حسب موقعك.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular, .accessoryInline
        ])
    }
}

// Widget إضافي (صغير) بتصميم مختلف للفجر فقط
@available(iOS 17.0, *)
struct prayer_widget_small_fajr: Widget {
    let kind: String = "prayerWidgetSmallFajr"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            prayer_widgetExtensionEntryView(entry: entry, smallLayout: .fajr)
        }
        .configurationDisplayName("أوقات الصلاة (الفجر)")
        .description("ودجت صغير بتصميم مخصص للفجر.")
        .supportedFamilies([.systemSmall])
    }
}
