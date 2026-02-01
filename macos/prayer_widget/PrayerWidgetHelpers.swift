//
//  PrayerWidgetHelpers.swift
//  prayer_widget
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

func convertToTime(from string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.timeZone = TimeZone.current

    guard !string.isEmpty else {
        print("Empty string provided for time conversion")
        return nil
    }

    let result = formatter.date(from: string)
    if result == nil {
        print("Failed to convert time string: \(string)")
    }

    return result
}

func TimeOnly(from string: String, languageCode: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.timeZone = TimeZone.current

    guard !string.isEmpty else {
        print("Empty string provided for time formatting")
        return nil
    }

    if let date = formatter.date(from: string) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.locale = Locale(identifier: languageCode)

        let timeString = timeFormatter.string(from: date)
        return convertNumbers(timeString, languageCode: languageCode)
    }

    print("Failed to format time from string: \(string)")
    return nil
}

func getNextPrayer(currentTime: Date, prayerTimes: [(name: String, time: String)]) -> (name: String, date: Date)? {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone.current

    let today = calendar.startOfDay(for: currentTime)

    var todayPrayers: [(name: String, date: Date)] = []

    for prayer in prayerTimes {
        if let originalDate = dateFormatter.date(from: prayer.time) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: originalDate)
            if let todayPrayerTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                   minute: timeComponents.minute ?? 0,
                                                   second: timeComponents.second ?? 0,
                                                   of: today) {
                todayPrayers.append((name: prayer.name, date: todayPrayerTime))
            }
        } else {
            print("Invalid time format for \(prayer.name): \(prayer.time)")
        }
    }

    for prayer in todayPrayers {
        if prayer.date > currentTime {
            print("الصلاة القادمة: \(prayer.name) - \(prayer.date)")
            return prayer
        }
    }

    if let fajr = todayPrayers.first {
        if let tomorrowFajr = calendar.date(byAdding: .day, value: 1, to: fajr.date) {
            return (name: fajr.name, date: tomorrowFajr)
        }
    }

    return nil
}

func getPrayerTimesForProgress(
    currentTime: Date,
    prayerTimes: [(name: String, time: String)]
) -> ((name: String, date: Date)?, (name: String, date: Date)?) {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone.current

    let today = calendar.startOfDay(for: currentTime)

    var todayPrayers: [(name: String, date: Date)] = []

    for prayer in prayerTimes {
        if let originalDate = dateFormatter.date(from: prayer.time) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: originalDate)
            if let todayPrayerTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                   minute: timeComponents.minute ?? 0,
                                                   second: timeComponents.second ?? 0,
                                                   of: today) {
                todayPrayers.append((name: prayer.name, date: todayPrayerTime))
            }
        } else {
            print("Invalid time format for \(prayer.name): \(prayer.time)")
        }
    }

    guard !todayPrayers.isEmpty else {
        return (nil, nil)
    }

    todayPrayers.sort { $0.date < $1.date }

    var nextDayFajr: (name: String, date: Date)? = nil
    if let fajr = todayPrayers.first {
        if let tomorrowFajr = calendar.date(byAdding: .day, value: 1, to: fajr.date) {
            nextDayFajr = (name: fajr.name, date: tomorrowFajr)
            todayPrayers.append(nextDayFajr!)
        }
    }

    for i in 0..<todayPrayers.count {
        let current = todayPrayers[i]
        let next = i + 1 < todayPrayers.count ? todayPrayers[i + 1] : nil

        if let next = next, currentTime >= current.date && currentTime < next.date {
            return (current, next)
        }
    }

    if let lastPrayer = todayPrayers.dropLast().last, let nextDayFajr = nextDayFajr {
        if currentTime >= lastPrayer.date {
            return (lastPrayer, nextDayFajr)
        }
    }

    return (todayPrayers.last, todayPrayers.first)
}

func getPreviousPrayer(currentTime: Date, prayerTimes: [(name: String, time: String)]) -> (name: String, date: Date)? {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone.current

    for prayer in prayerTimes.reversed() {
        if let prayerTime = dateFormatter.date(from: prayer.time) {
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: prayerTime)
            if let todayPrayerTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                   minute: timeComponents.minute ?? 0,
                                                   second: timeComponents.second ?? 0,
                                                   of: calendar.startOfDay(for: currentTime)) {
                if todayPrayerTime < currentTime {
                    return (name: prayer.name, date: todayPrayerTime)
                }
            }
        }
    }

    return nil
}

func convertNumbers(_ string: String, languageCode: String) -> String {
    guard languageCode == "ar" || languageCode == "ur" || languageCode == "fa" else {
        return string
    }

    let arabicNumerals = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
    let westernNumerals = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    var result = string
    for (index, western) in westernNumerals.enumerated() {
        result = result.replacingOccurrences(of: western, with: arabicNumerals[index])
    }

    return result
}

func debugDumpPrayerWidgetKeys(_ ud: UserDefaults?) {
    let appGroupId = "group.alheekmah.aqimApp.prayerWidget"
    let fileName = "widget_payload.json"

    var filePayload: [String: Any] = [:]
    if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
        let fileURL = container.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            if let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                filePayload = obj
            }
            print("[Widget][File] payload=ok path=\(fileURL.path)")
        } catch {
            print("[Widget][File] payload=missing/invalid error=\(error)")
        }
    } else {
        print("[Widget][File] containerURL=nil for \(appGroupId)")
    }

    let expectedKeys = [
        "fajrTime", "sunriseTime", "dhuhrTime", "asrTime", "maghribTime", "ishaTime",
        "middleOfTheNightTime", "lastThirdOfTheNightTime",
        "fajrName", "sunriseName", "dhuhrName", "asrName", "maghribName", "ishaName",
        "middleOfTheNightName", "lastThirdOfTheNightName",
        "hijriDay", "hijriDayName", "hijriMonth", "hijriYear",
        "appLanguage", "monthly_prayer_data",
        "lastUpdated", "__macos_widget_initialized", "__macos_widget_last_write"
    ]

    var lines: [String] = []
    for k in expectedKeys {
        if let v = ud?.object(forKey: k) {
            lines.append("\(k)=\(v)")
        } else if let v = filePayload[k] {
            lines.append("\(k)=\(v) [file]")
        } else {
            lines.append("\(k)=<nil>")
        }
    }

    print("[Widget][UD][Dump] " + lines.joined(separator: ", "))

    if (ud?.object(forKey: "fajrTime") == nil) && (filePayload["fajrTime"] == nil) {
        print("[Widget][UD] fajrTime is nil (daily data not present)")
    }
}
