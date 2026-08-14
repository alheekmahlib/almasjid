//
//  Provider.swift
//  prayer_widget
//

import Foundation
import WidgetKit
import SwiftUI

private let prayerWidgetAppGroupId = "group.alheekmah.aqimApp.prayerWidget"
private let prayerWidgetSharedPayloadFileName = "widget_payload.json"

private struct PrayerWidgetSharedStore {
    let userDefaults: UserDefaults?
    let filePayload: [String: Any]

    func string(forKey key: String) -> String? {
        if let v = filePayload[key] as? String, !v.isEmpty { return v }
        if let v = userDefaults?.string(forKey: key), !v.isEmpty { return v }
        return nil
    }
}

private struct PrayerWidgetDayData {
    let prayerTimes: [(name: String, time: String)] // 6 items (incl. sunrise)
    let mainPrayers: [(name: String, time: String)] // 5 items (excl. sunrise)
    let middleOfTheNightDate: String
    let lastThirdOfTheNightDate: String
}

struct Provider: TimelineProvider {
    typealias Entry = PrayerWidgetEntry

    private func loadSharedPayloadFile(debug: Bool) -> [String: Any] {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: prayerWidgetAppGroupId) else {
            #if DEBUG
            if debug { print("[Widget][File] containerURL is nil for \(prayerWidgetAppGroupId)") }
            #endif
            return [:]
        }
        let fileURL = container.appendingPathComponent(prayerWidgetSharedPayloadFileName)
        do {
            let data = try Data(contentsOf: fileURL)
            let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            #if DEBUG
            if debug { print("[Widget][File] Loaded payload file: \(fileURL.path)") }
            #endif
            return obj ?? [:]
        } catch {
            #if DEBUG
            if debug { print("[Widget][File] No/invalid payload file at \(fileURL.path): \(error)") }
            #endif
            return [:]
        }
    }

    func placeholder(in context: Context) -> PrayerWidgetEntry {
        let lang = "ar"
        let today = ISO8601DateFormatter().string(from: Date())
        let dayPrefix = String(today.prefix(10))
        let mainPrayers: [(name: String, time: String)] = [
            (name: "الفجر", time: "\(dayPrefix) 05:30:00.000"),
            (name: "الظهر", time: "\(dayPrefix) 12:00:00.000"),
            (name: "العصر", time: "\(dayPrefix) 15:30:00.000"),
            (name: "المغرب", time: "\(dayPrefix) 18:00:00.000"),
            (name: "العشاء", time: "\(dayPrefix) 19:30:00.000")
        ]
        return PrayerWidgetEntry(
            date: Date(), fajrName: "Fajir", fajrDate: "0",
            sunriseName: "Sunrise", sunriseDate: "0", dhuhrName: "Dhuhr",
            dhuhrDate: "0", asrName: "Asr", asrDate: "0",
            maghribName: "Maghrib", maghribDate: "0", ishaName: "Isha",
            ishaDate: "0",
            middleOfTheNightName: "Maghrib", middleOfTheNightDate: "0",
            lastThirdOfTheNightName: "Isha",
            lastThirdOfTheNightDate: "0",
            hijriDay: convertNumbers("1", languageCode: lang),
            hijriDayName: "الجمعة",
            hijriMonth: "1",
            hijriYear: convertNumbers("1446", languageCode: lang),
            nextPrayerDate: Date().addingTimeInterval(3600),
            currentPrayerTime: Date().addingTimeInterval(3600),
            appLanguage: lang,
            displaySize: context.displaySize,
            prayerTimes: mainPrayers
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        let userDefaults = UserDefaults(suiteName: prayerWidgetAppGroupId)
        let payload = loadSharedPayloadFile(debug: false)
        let store = PrayerWidgetSharedStore(userDefaults: userDefaults, filePayload: payload)
        let cached = loadDayData(currentDate: Date(), store: store, debug: false)
        completion(createEntry(date: Date(), displaySize: context.displaySize, cachedDayData: cached, store: store, debug: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let now = Date()
        let userDefaults = UserDefaults(suiteName: prayerWidgetAppGroupId)
        let payload = loadSharedPayloadFile(debug: true)
        let store = PrayerWidgetSharedStore(userDefaults: userDefaults, filePayload: payload)
        let cached = loadDayData(currentDate: now, store: store, debug: true)

        let firstEntry = createEntry(date: now, displaySize: context.displaySize, cachedDayData: cached, store: store, debug: true)
        let cal = Calendar.current

        let nextPrayerDate = getNextPrayer(currentTime: now, prayerTimes: firstEntry.prayerTimes)?.date
        let nextMidnight = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now))?.addingTimeInterval(5)

        var targetDateCandidates: [Date] = []
        if let np = nextPrayerDate { targetDateCandidates.append(np) }
        if let md = nextMidnight { targetDateCandidates.append(md) }
        let targetDate = targetDateCandidates.min() ?? now.addingTimeInterval(3600)

        let distance = targetDate.timeIntervalSince(now)
        let fiveMinutes: TimeInterval = 300
        let oneMinute: TimeInterval = 60
        let switchToMinuteThreshold: TimeInterval = 3600

        var entries: [PrayerWidgetEntry] = [firstEntry]

        if distance <= switchToMinuteThreshold {
            var cursor = now.addingTimeInterval(oneMinute)
            while cursor <= targetDate {
                entries.append(createEntry(date: cursor, displaySize: context.displaySize, cachedDayData: cached, store: store, debug: false))
                cursor = cursor.addingTimeInterval(oneMinute)
            }
        } else {
            let minutePhaseStart = targetDate.addingTimeInterval(-switchToMinuteThreshold)
            var cursor = now.addingTimeInterval(fiveMinutes)
            while cursor < minutePhaseStart {
                entries.append(createEntry(date: cursor, displaySize: context.displaySize, cachedDayData: cached, store: store, debug: false))
                cursor = cursor.addingTimeInterval(fiveMinutes)
            }
            cursor = minutePhaseStart
            while cursor <= targetDate {
                entries.append(createEntry(date: cursor, displaySize: context.displaySize, cachedDayData: cached, store: store, debug: false))
                cursor = cursor.addingTimeInterval(oneMinute)
            }
        }

        #if DEBUG
        print("[Timeline] entries: \(entries.count), target: \(targetDate), nextPrayer: \(String(describing: nextPrayerDate))")
        #endif
        completion(Timeline(entries: entries, policy: .after(targetDate)))
    }

    private func loadDayData(
        currentDate: Date,
        store: PrayerWidgetSharedStore,
        debug: Bool
    ) -> PrayerWidgetDayData {
        let calendar = Calendar.current
        let currentDateString = ISO8601DateFormatter().string(from: currentDate)

        func convertPrayerTimeToToday(timeString: String) -> String {
            if let prayerTime = convertToTime(from: timeString) {
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: prayerTime)
                if let todayTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                 minute: timeComponents.minute ?? 0,
                                                 second: timeComponents.second ?? 0,
                                                 of: calendar.startOfDay(for: currentDate)) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                    formatter.timeZone = TimeZone.current
                    return formatter.string(from: todayTime)
                }
            }
            return timeString
        }

        let defaultFormatter: DateFormatter = {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"; f.timeZone = TimeZone.current; return f
        }()
        let isoFormatter = ISO8601DateFormatter()

        var prayerTimes: [(name: String, time: String)] = []
        var mainPrayers: [(name: String, time: String)] = []

        let hasDailyData = store.string(forKey: "fajrTime") != nil

        var middleOfTheNightDate: String = "\(currentDateString.prefix(10)) 00:00:00.000"
        var lastThirdOfTheNightDate: String = "\(currentDateString.prefix(10)) 00:00:00.000"

        if hasDailyData {
            #if DEBUG
            if debug { print("[Widget] Using daily individual prayer times") }
            #endif

            let fajrDaily = store.string(forKey: "fajrTime") ?? "\(currentDateString.prefix(10)) 05:48:00.000"
            let sunriseDaily = store.string(forKey: "sunriseTime") ?? "\(currentDateString.prefix(10)) 07:15:00.000"
            let dhuhrDaily = store.string(forKey: "dhuhrTime") ?? "\(currentDateString.prefix(10)) 11:56:00.000"
            let asrDaily = store.string(forKey: "asrTime") ?? "\(currentDateString.prefix(10)) 14:13:00.000"
            let maghribDaily = store.string(forKey: "maghribTime") ?? "\(currentDateString.prefix(10)) 16:35:00.000"
            let ishaDaily = store.string(forKey: "ishaTime") ?? "\(currentDateString.prefix(10)) 18:01:00.000"

            prayerTimes = [
                 (name: store.string(forKey: "fajrName") ?? "الفجر",
                 time: convertPrayerTimeToToday(timeString: fajrDaily)),
                 (name: store.string(forKey: "sunriseName") ?? "الشروق",
                 time: convertPrayerTimeToToday(timeString: sunriseDaily)),
                 (name: store.string(forKey: "dhuhrName") ?? "الظهر",
                 time: convertPrayerTimeToToday(timeString: dhuhrDaily)),
                 (name: store.string(forKey: "asrName") ?? "العصر",
                 time: convertPrayerTimeToToday(timeString: asrDaily)),
                 (name: store.string(forKey: "maghribName") ?? "المغرب",
                 time: convertPrayerTimeToToday(timeString: maghribDaily)),
                 (name: store.string(forKey: "ishaName") ?? "العشاء",
                 time: convertPrayerTimeToToday(timeString: ishaDaily))
            ]

            mainPrayers = [
                (name: prayerTimes[0].name, time: prayerTimes[0].time),
                (name: prayerTimes[2].name, time: prayerTimes[2].time),
                (name: prayerTimes[3].name, time: prayerTimes[3].time),
                (name: prayerTimes[4].name, time: prayerTimes[4].time),
                (name: prayerTimes[5].name, time: prayerTimes[5].time)
            ]

            middleOfTheNightDate = convertPrayerTimeToToday(timeString: store.string(forKey: "middleOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000")
            lastThirdOfTheNightDate = convertPrayerTimeToToday(timeString: store.string(forKey: "lastThirdOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000")
        }

        if prayerTimes.isEmpty {
            #if DEBUG
            if debug { print("[Widget][Fallback] No data found, using placeholder defaults") }
            #endif
            let defaultTime = "\(currentDateString.prefix(10)) 12:00:00.000"
            prayerTimes = [
                (name: "الفجر", time: convertPrayerTimeToToday(timeString: defaultTime)),
                (name: "الشروق", time: convertPrayerTimeToToday(timeString: defaultTime)),
                (name: "الظهر", time: convertPrayerTimeToToday(timeString: defaultTime)),
                (name: "العصر", time: convertPrayerTimeToToday(timeString: defaultTime)),
                (name: "المغرب", time: convertPrayerTimeToToday(timeString: defaultTime)),
                (name: "العشاء", time: convertPrayerTimeToToday(timeString: defaultTime))
            ]
        }

        if mainPrayers.isEmpty {
            mainPrayers = [
                (name: prayerTimes[0].name, time: prayerTimes[0].time),
                (name: prayerTimes[2].name, time: prayerTimes[2].time),
                (name: prayerTimes[3].name, time: prayerTimes[3].time),
                (name: prayerTimes[4].name, time: prayerTimes[4].time),
                (name: prayerTimes[5].name, time: prayerTimes[5].time)
            ]
        }

        if middleOfTheNightDate.isEmpty {
            middleOfTheNightDate = "\(currentDateString.prefix(10)) 00:00:00.000"
        }
        if lastThirdOfTheNightDate.isEmpty {
            lastThirdOfTheNightDate = "\(currentDateString.prefix(10)) 00:00:00.000"
        }

        return PrayerWidgetDayData(
            prayerTimes: prayerTimes,
            mainPrayers: mainPrayers,
            middleOfTheNightDate: middleOfTheNightDate,
            lastThirdOfTheNightDate: lastThirdOfTheNightDate
        )
    }

    private func createEntry(
        date: Date = Date(),
        displaySize: CGSize? = nil,
        cachedDayData: PrayerWidgetDayData? = nil,
        store: PrayerWidgetSharedStore,
        debug: Bool = false
    ) -> PrayerWidgetEntry {
        let currentDate = date
        #if DEBUG
        if debug { debugDumpPrayerWidgetKeys(UserDefaults(suiteName: prayerWidgetAppGroupId)) }
        #endif

        let appLanguage = store.string(forKey: "appLanguage") ?? "ar"
        let dayData = cachedDayData ?? loadDayData(currentDate: currentDate, store: store, debug: debug)

        #if DEBUG
        if debug {
            print("[Widget] Current date: \(currentDate)")
            print("[Widget] Loaded prayerTimes: \(dayData.prayerTimes)")
            print("[Widget] Main prayers (without sunrise): \(dayData.mainPrayers)")
        }
        #endif

        let nextPrayer = getNextPrayer(currentTime: currentDate, prayerTimes: dayData.mainPrayers)

        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        var fallbackHijriDay = "1"
        var fallbackHijriMonth = "1"
        var fallbackHijriYear = "1446"
        var fallbackHijriDayName = appLanguage == "ar" ? "الجمعة" : "Friday"
        let hijriComponents = hijriCalendar.dateComponents([.day, .month, .year], from: currentDate)
        if let d = hijriComponents.day { fallbackHijriDay = convertNumbers(String(d), languageCode: appLanguage) }
        if let m = hijriComponents.month { fallbackHijriMonth = String(m) }
        if let y = hijriComponents.year { fallbackHijriYear = convertNumbers(String(y), languageCode: appLanguage) }
        let hijriNameFormatter = DateFormatter()
        hijriNameFormatter.calendar = hijriCalendar
        hijriNameFormatter.locale = Locale(identifier: appLanguage)
        hijriNameFormatter.dateFormat = "EEEE"
        fallbackHijriDayName = hijriNameFormatter.string(from: currentDate)

        return PrayerWidgetEntry(
            date: currentDate,
            fajrName: dayData.prayerTimes[0].name, fajrDate: dayData.prayerTimes[0].time,
            sunriseName: dayData.prayerTimes[1].name, sunriseDate: dayData.prayerTimes[1].time,
            dhuhrName: dayData.prayerTimes[2].name, dhuhrDate: dayData.prayerTimes[2].time,
            asrName: dayData.prayerTimes[3].name, asrDate: dayData.prayerTimes[3].time,
            maghribName: dayData.prayerTimes[4].name, maghribDate: dayData.prayerTimes[4].time,
            ishaName: dayData.prayerTimes[5].name, ishaDate: dayData.prayerTimes[5].time,
            middleOfTheNightName: store.string(forKey: "middleOfTheNightName") ?? "منتصف الليل",
            middleOfTheNightDate: dayData.middleOfTheNightDate,
            lastThirdOfTheNightName: store.string(forKey: "lastThirdOfTheNightName") ?? "ثلث الليل الأخير",
            lastThirdOfTheNightDate: dayData.lastThirdOfTheNightDate,
            hijriDay: convertNumbers(store.string(forKey: "hijriDay") ?? fallbackHijriDay, languageCode: appLanguage),
            hijriDayName: store.string(forKey: "hijriDayName") ?? fallbackHijriDayName,
            hijriMonth: store.string(forKey: "hijriMonth") ?? fallbackHijriMonth,
            hijriYear: convertNumbers(store.string(forKey: "hijriYear") ?? fallbackHijriYear, languageCode: appLanguage),
            nextPrayerDate: nextPrayer?.date ?? Date().addingTimeInterval(3600),
            currentPrayerTime: currentDate,
            appLanguage: appLanguage,
            displaySize: displaySize ?? CGSize(width: 300, height: 300),
            prayerTimes: dayData.mainPrayers
        )
    }
}
