//
//  PrayerWidget.swift
//  prayer_widget
//

import WidgetKit
import SwiftUI

@available(macOSApplicationExtension 14.0, *)
struct prayer_widget: Widget {
    // تحذير: لا تُغيّر هذه القيمة! تغييرها قد يحذف الـ widget من شاشات المستخدمين
    // WARNING: Do NOT change this value! Changing it can remove the widget from users' screens
    let kind: String = "prayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            prayer_widgetExtensionEntryView(entry: entry, smallLayout: .standard)
        }
        .configurationDisplayName("أوقات الصلاة")
        .description("ابقَ على اطلاع بمواقيت الصلاة اليومية بدقة مع تحديث تلقائي.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge
        ])
    }
}

@available(macOSApplicationExtension 14.0, *)
struct prayer_widget_small_fajr: Widget {
    let kind: String = "prayerWidgetSmallFajr"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            prayer_widgetExtensionEntryView(entry: entry, smallLayout: .fajr)
        }
        .configurationDisplayName("أوقات الصلاة (الفجر)")
        .description("ودجت صغير بتصميم مخصص للفجر.")
        .supportedFamilies([.systemSmall])
    }
}
