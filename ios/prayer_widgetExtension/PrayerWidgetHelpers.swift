//
//  PrayerWidgetHelpers.swift
//  prayer_widgetExtension
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

    // التحقق من صحة النص قبل التحويل - Validate text before conversion
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
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"  // التنسيق الكامل للقيمة المستلمة - Full format for received value
    formatter.timeZone = TimeZone.current

    // التحقق من صحة النص قبل التحويل - Validate text before conversion
    guard !string.isEmpty else {
        print("Empty string provided for time formatting")
        return nil
    }

    if let date = formatter.date(from: string) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"  // التنسيق للوقت فقط - Format for time only
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.locale = Locale(identifier: languageCode)  // استخدام معرف اللغة المرسل - Use sent language identifier

        let timeString = timeFormatter.string(from: date)
        return convertNumbers(timeString, languageCode: languageCode)
    }

    print("Failed to format time from string: \(string)")
    return nil  // إذا فشل التحويل - If conversion fails
}

func getNextPrayer(currentTime: Date, prayerTimes: [(name: String, time: String)]) -> (name: String, date: Date)? {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone.current

    // الحصول على التاريخ الحالي - Get current date
    let today = calendar.startOfDay(for: currentTime)

    var todayPrayers: [(name: String, date: Date)] = []

    // تحويل أوقات الصلاة إلى اليوم الحالي - Convert prayer times to today
    for prayer in prayerTimes {
        if let originalDate = dateFormatter.date(from: prayer.time) {
            // استخراج الوقت فقط وتطبيقه على اليوم الحالي - Extract time only and apply to today
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

    // البحث عن الصلاة القادمة - Find next prayer
    for prayer in todayPrayers {
        if prayer.date > currentTime {
            print("الصلاة القادمة: \(prayer.name) - \(prayer.date)")
            return prayer
        }
    }

    // إذا لم توجد صلاة قادمة اليوم، فالصلاة القادمة هي الفجر غداً - If no prayer today, next is Fajr tomorrow
    if let fajr = todayPrayers.first {
        if let nextDayFajr = calendar.date(byAdding: .day, value: 1, to: fajr.date) {
            print("الصلاة القادمة (غداً): \(fajr.name) - \(nextDayFajr)")
            return (name: fajr.name, date: nextDayFajr)
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

    // الحصول على التاريخ الحالي - Get current date
    let today = calendar.startOfDay(for: currentTime)

    var todayPrayers: [(name: String, date: Date)] = []

    // تحويل أوقات الصلاة إلى اليوم الحالي - Convert prayer times to today
    for prayer in prayerTimes {
        if let originalDate = dateFormatter.date(from: prayer.time) {
            // استخراج الوقت فقط وتطبيقه على اليوم الحالي - Extract time only and apply to today
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: originalDate)
            if let todayPrayerTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                  minute: timeComponents.minute ?? 0,
                                                  second: timeComponents.second ?? 0,
                                                  of: today) {
                todayPrayers.append((name: prayer.name, date: todayPrayerTime))
            }
        } else {
            print("Invalid prayer time format for \(prayer.name): \(prayer.time)")
        }
    }

    guard !todayPrayers.isEmpty else {
        print("لم يتم العثور على صلوات لليوم الحالي - No prayers found for today.")
        return (nil, nil)
    }

    // ترتيب الصلوات بناءً على الوقت - Sort prayers by time
    todayPrayers.sort { $0.date < $1.date }

    // إضافة صلاة الفجر لليوم التالي بعد الترتيب - Add next day's Fajr after sorting
    var nextDayFajr: (name: String, date: Date)? = nil
    if let fajr = todayPrayers.first {
        if let nextFajrDate = calendar.date(byAdding: .day, value: 1, to: fajr.date) {
            nextDayFajr = (name: fajr.name, date: nextFajrDate)
            todayPrayers.append(nextDayFajr!)
        }
    }

    // إيجاد الصلاة الحالية والقادمة - Find current and next prayer
    for i in 0..<todayPrayers.count {
        if todayPrayers[i].date > currentTime {
            let currentPrayer = i > 0 ? todayPrayers[i - 1] : todayPrayers.last
            let nextPrayer = todayPrayers[i]

            print("[Progress] الصلاة الحالية: \(currentPrayer?.name ?? "غير محدد") - \(currentPrayer?.date ?? Date())")
            print("[Progress] الصلاة القادمة: \(nextPrayer.name) - \(nextPrayer.date)")

            return (currentPrayer, nextPrayer)
        }
    }

    // إذا تجاوزنا كل الصلوات (بعد العشاء)، الصلاة الحالية هي العشاء والقادمة هي فجر الغد
    // If past all prayers (after Isha), current is Isha and next is tomorrow's Fajr
    if let lastPrayer = todayPrayers.dropLast().last, // العشاء (قبل فجر الغد)
       let tomorrowFajr = nextDayFajr {
        print("[Progress] بعد العشاء - الحالية: \(lastPrayer.name) - \(lastPrayer.date)")
        print("[Progress] القادمة (فجر الغد): \(tomorrowFajr.name) - \(tomorrowFajr.date)")
        return (lastPrayer, tomorrowFajr)
    }

    return (todayPrayers.last, todayPrayers.first)
}

func getPreviousPrayer(currentTime: Date, prayerTimes: [(name: String, time: String)]) -> (name: String, date: Date)? {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone.current

    // البحث عن الصلاة السابقة من خلال التنازلي - Search for previous prayer in reverse order
    for prayer in prayerTimes.reversed() {
        if let prayerDate = dateFormatter.date(from: prayer.time) {
            // إذا كان وقت الصلاة أكبر من الوقت الحالي، احسب لليوم السابق
            // If prayer time is greater than current time, calculate for previous day
            var adjustedDate = prayerDate
            if prayerDate > currentTime {
                adjustedDate = calendar.date(byAdding: .day, value: -1, to: prayerDate) ?? prayerDate
            }

            if adjustedDate <= currentTime {
                return (name: prayer.name, date: adjustedDate)
            }
        }
    }

    return nil
}

// دالة تحويل الأرقام حسب اللغة - Convert numbers based on language
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

// دالة لتفريغ المفاتيح والقيم ذات الصلة في مجموعة التطبيق - Dump relevant app group keys
func debugDumpPrayerWidgetKeys(_ ud: UserDefaults?) {
    guard let ud = ud else {
        print("[Widget][UD] UserDefaults nil")
        return
    }
    let expectedKeys = [
        "fajrTime","sunriseTime","dhuhrTime","asrTime","maghribTime","ishaTime",
        "middleOfTheNightTime","lastThirdOfTheNightTime","monthly_prayer_data",
        "fajrName","sunriseName","dhuhrName","asrName","maghribName","ishaName",
        "middleOfTheNightName","lastThirdOfTheNightName","hijriDay","hijriMonth","hijriYear","appLanguage"
    ]
    var lines: [String] = []
    for k in expectedKeys {
        if let v = ud.object(forKey: k) {
            if k == "monthly_prayer_data", let s = v as? String {
                lines.append("\(k)=len:\(s.count)")
            } else {
                lines.append("\(k)=\(v)")
            }
        } else {
            lines.append("\(k)=<missing>")
        }
    }
    print("[Widget][UD][Dump] " + lines.joined(separator: ", "))
    if ud.object(forKey: "fajrTime") == nil {
        print("[Widget][UD][Warn] fajrTime مفقود؛ سيتم استخدام قيم افتراضية. افتح التطبيق بعد تعديل App Group للتحديث.")
    }
}
