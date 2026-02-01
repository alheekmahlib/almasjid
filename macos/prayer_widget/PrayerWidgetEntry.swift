//
//  PrayerWidgetEntry.swift
//  prayer_widget
//

import WidgetKit
import SwiftUI

struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let fajrName: String
    let fajrDate: String
    let sunriseName: String
    let sunriseDate: String
    let dhuhrName: String
    let dhuhrDate: String
    let asrName: String
    let asrDate: String
    let maghribName: String
    let maghribDate: String
    let ishaName: String
    let ishaDate: String
    let middleOfTheNightName: String
    let middleOfTheNightDate: String
    let lastThirdOfTheNightName: String
    let lastThirdOfTheNightDate: String
    let hijriDay: String
    let hijriDayName: String
    let hijriMonth: String
    let hijriYear: String
    let nextPrayerDate: Date
    let currentPrayerTime: Date
    let appLanguage: String
    let displaySize: CGSize
    let prayerTimes: [(name: String, time: String)]
}
