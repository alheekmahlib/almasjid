//
//  Provider.swift
//  prayer_widgetExtension
//

import Foundation
import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    typealias Entry = PrayerWidgetEntry
    typealias Intent = ConfigurationAppIntent

    func placeholder(in context: Context) -> PrayerWidgetEntry {
        let lang = "ar"
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
            displaySize: context.displaySize, prayerTimes: [])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PrayerWidgetEntry {
        return createEntry()
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PrayerWidgetEntry> {
        let now = Date()
        let firstEntry = createEntry(date: now)
        let cal = Calendar.current

        // وقت الصلاة القادمة و منتصف الليل القادم - Next prayer & midnight
        let nextPrayerDate = getNextPrayer(currentTime: now, prayerTimes: firstEntry.prayerTimes)?.date
        let nextMidnight = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now))?.addingTimeInterval(5)

        // الهدف الأساسي: التحديث حتى الصلاة القادمة، أو منتصف الليل عند عبور اليوم
        var targetDateCandidates: [Date] = []
        if let np = nextPrayerDate { targetDateCandidates.append(np) }
        if let md = nextMidnight { targetDateCandidates.append(md) }
        let targetDate = targetDateCandidates.min() ?? now.addingTimeInterval(3600)

        // إذا كانت الصلاة القادمة بعيدة جدًا (> 4 ساعات) نقلل التردد: كل 5 دقائق حتى نقترب آخر ساعة ثم كل دقيقة
        let distance = targetDate.timeIntervalSince(now)
        let fiveMinutes: TimeInterval = 300
        let oneMinute: TimeInterval = 60
        let switchToMinuteThreshold: TimeInterval = 3600 // آخر ساعة قبل الصلاة

        var entries: [PrayerWidgetEntry] = [firstEntry]

        if distance <= switchToMinuteThreshold {
            // تحديث دقيق لكل دقيقة حتى الهدف
            var cursor = now.addingTimeInterval(oneMinute)
            while cursor <= targetDate {
                entries.append(createEntry(date: cursor))
                cursor = cursor.addingTimeInterval(oneMinute)
            }
        } else {
            // مرحلة أولى: تحديث كل 5 دقائق حتى نصل إلى آخر ساعة
            let minutePhaseStart = targetDate.addingTimeInterval(-switchToMinuteThreshold)
            var cursor = now.addingTimeInterval(fiveMinutes)
            while cursor < minutePhaseStart {
                entries.append(createEntry(date: cursor))
                cursor = cursor.addingTimeInterval(fiveMinutes)
            }
            // مرحلة ثانية: آخر ساعة دقيقةً بدقيقة
            cursor = minutePhaseStart
            while cursor <= targetDate {
                entries.append(createEntry(date: cursor))
                cursor = cursor.addingTimeInterval(oneMinute)
            }
        }

        // تأكيد وعرض العدد - debug
        print("[Timeline] entries: \(entries.count), target: \(targetDate), nextPrayer: \(String(describing: nextPrayerDate))")
        return Timeline(entries: entries, policy: .after(targetDate))
    }

    func createEntry(date: Date = Date()) -> PrayerWidgetEntry {
        // استخدام UserDefaults للوصول إلى بيانات التطبيق - Use UserDefaults to access app data
        let userDefaults = UserDefaults(suiteName: "group.alheekmah.aqimApp.prayerWidget")
        debugDumpPrayerWidgetKeys(userDefaults) // تفريغ مفاتيح المجموعة للتشخيص

        // الحصول على التاريخ الحالي لاستخدامه مع الأوقات - Get current date to use with times
        let currentDate = date
        let calendar = Calendar.current
        let currentDateString = ISO8601DateFormatter().string(from: currentDate)
        let appLanguage = userDefaults?.string(forKey: "appLanguage") ?? "ar"

        // دالة لتحويل وقت الصلاة إلى التاريخ الحالي - Function to convert prayer time to current date
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

        // استخدام البيانات الفردية (اليومية) أولاً لأنها تتحدث مع كل فتح للتطبيق
        // Use individual (daily) data first as it updates with each app open
        let defaultFormatter: DateFormatter = {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"; f.timeZone = TimeZone.current; return f
        }()
        let isoFormatter = ISO8601DateFormatter()

        var prayerTimes: [(name: String, time: String)] = []
        var mainPrayers: [(name: String, time: String)] = []
        var monthlyMiddleOfNight: String? = nil
        var monthlyLastThird: String? = nil

        // المسار الأول: محاولة قراءة بيانات الشهر الكامل (أدق من البيانات اليومية القديمة)
        // Path 1: Try reading full-month data (more accurate than stale daily data)
        let components = calendar.dateComponents([.year, .month, .day], from: currentDate)

        // نبحث في مفتاح الشهر المحدد أولاً ثم المفتاح العام القديم
        var monthlyJson: String? = nil
        let monthSpecificKey = "monthly_prayer_times_\(components.year ?? 0)_\(components.month ?? 0)"
        monthlyJson = userDefaults?.string(forKey: monthSpecificKey)
        if monthlyJson == nil {
            // التوافقية مع المفتاح القديم
            monthlyJson = userDefaults?.string(forKey: "monthly_prayer_times")
        }
        if let monthlyJson = monthlyJson,
           let jsonData = monthlyJson.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let storedYear = parsed["year"] as? Int,
           let storedMonth = parsed["month"] as? Int,
           let days = parsed["days"] as? [String: String] {

            let currentDay = components.day ?? 0

            if storedYear == components.year && storedMonth == components.month,
               let dayString = days["\(currentDay)"] {
                // الصيغة: fajr|sunrise|dhuhr|asr|maghrib|isha|midnight|lastThird (HH:mm)
                let parts = dayString.split(separator: "|").map(String.init)
                if parts.count == 8 {
                    let datePrefix = defaultFormatter.string(from: calendar.startOfDay(for: currentDate)).prefix(10)

                    func buildTimeString(_ hhmm: String) -> String {
                        return "\(datePrefix) \(hhmm):00.000"
                    }

                    let fajrStr = buildTimeString(parts[0])
                    let sunriseStr = buildTimeString(parts[1])
                    let dhuhrStr = buildTimeString(parts[2])
                    let asrStr = buildTimeString(parts[3])
                    let maghribStr = buildTimeString(parts[4])
                    let ishaStr = buildTimeString(parts[5])
                    monthlyMiddleOfNight = buildTimeString(parts[6])
                    monthlyLastThird = buildTimeString(parts[7])

                    print("[Widget] Using monthly data for day \(currentDay): \(dayString)")

                    // أسماء الصلوات من المفاتيح الفردية (لا تتغير يوميًا)
                    prayerTimes = [
                        (name: userDefaults?.string(forKey: "fajrName") ?? "الفجر", time: fajrStr),
                        (name: userDefaults?.string(forKey: "sunriseName") ?? "الشروق", time: sunriseStr),
                        (name: userDefaults?.string(forKey: "dhuhrName") ?? "الظهر", time: dhuhrStr),
                        (name: userDefaults?.string(forKey: "asrName") ?? "العصر", time: asrStr),
                        (name: userDefaults?.string(forKey: "maghribName") ?? "المغرب", time: maghribStr),
                        (name: userDefaults?.string(forKey: "ishaName") ?? "العشاء", time: ishaStr)
                    ]

                    mainPrayers = [
                        (name: prayerTimes[0].name, time: prayerTimes[0].time),
                        (name: prayerTimes[2].name, time: prayerTimes[2].time),
                        (name: prayerTimes[3].name, time: prayerTimes[3].time),
                        (name: prayerTimes[4].name, time: prayerTimes[4].time),
                        (name: prayerTimes[5].name, time: prayerTimes[5].time)
                    ]
                }
            }
        }

        // المسار الثاني: البيانات اليومية الفردية (إذا لم تتوفر بيانات شهرية)
        // Path 2: Daily individual data fallback (when no monthly data available)
        let hasDailyData = userDefaults?.string(forKey: "fajrTime") != nil

        if prayerTimes.isEmpty && hasDailyData {
            // استخدام البيانات اليومية الفردية - Use daily individual prayer times
            print("[Widget] Using daily individual prayer times")
            let fajrDaily = userDefaults?.string(forKey: "fajrTime") ?? "\(currentDateString.prefix(10)) 05:48:00.000"
            let sunriseDaily = userDefaults?.string(forKey: "sunriseTime") ?? "\(currentDateString.prefix(10)) 07:15:00.000"
            let dhuhrDaily = userDefaults?.string(forKey: "dhuhrTime") ?? "\(currentDateString.prefix(10)) 11:56:00.000"
            let asrDaily = userDefaults?.string(forKey: "asrTime") ?? "\(currentDateString.prefix(10)) 14:13:00.000"
            let maghribDaily = userDefaults?.string(forKey: "maghribTime") ?? "\(currentDateString.prefix(10)) 16:35:00.000"
            let ishaDaily = userDefaults?.string(forKey: "ishaTime") ?? "\(currentDateString.prefix(10)) 18:01:00.000"

            print("[Widget][Daily] fajr=\(fajrDaily), dhuhr=\(dhuhrDaily), asr=\(asrDaily), maghrib=\(maghribDaily), isha=\(ishaDaily)")

            prayerTimes = [
                (name: userDefaults?.string(forKey: "fajrName") ?? "الفجر",
                 time: convertPrayerTimeToToday(timeString: fajrDaily)),
                (name: userDefaults?.string(forKey: "sunriseName") ?? "الشروق",
                 time: convertPrayerTimeToToday(timeString: sunriseDaily)),
                (name: userDefaults?.string(forKey: "dhuhrName") ?? "الظهر",
                 time: convertPrayerTimeToToday(timeString: dhuhrDaily)),
                (name: userDefaults?.string(forKey: "asrName") ?? "العصر",
                 time: convertPrayerTimeToToday(timeString: asrDaily)),
                (name: userDefaults?.string(forKey: "maghribName") ?? "المغرب",
                 time: convertPrayerTimeToToday(timeString: maghribDaily)),
                (name: userDefaults?.string(forKey: "ishaName") ?? "العشاء",
                 time: convertPrayerTimeToToday(timeString: ishaDaily))
            ]

            mainPrayers = [
                (name: prayerTimes[0].name, time: prayerTimes[0].time),
                (name: prayerTimes[2].name, time: prayerTimes[2].time),
                (name: prayerTimes[3].name, time: prayerTimes[3].time),
                (name: prayerTimes[4].name, time: prayerTimes[4].time),
                (name: prayerTimes[5].name, time: prayerTimes[5].time)
            ]
        }

        if prayerTimes.isEmpty {
            // Last fallback - use default placeholder values
            print("[Widget][Fallback] No data found, using placeholder defaults")
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

        // تأكيد البيانات - Confirm data
        print("[Widget] Current date: \(currentDate)")
        print("[Widget] Loaded prayerTimes: \(prayerTimes)")
        print("[Widget] Main prayers (without sunrise): \(mainPrayers)")

        let nextPrayer = getNextPrayer(currentTime: currentDate, prayerTimes: mainPrayers)

        // حساب التاريخ الهجري محليًا دائمًا بناءً على currentDate لأن UserDefaults لا تُحدَّث بدون فتح التطبيق
        // Always compute Hijri date locally from currentDate since UserDefaults aren't updated without opening the app
        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        var computedHijriDay = "1"
        var computedHijriMonth = "1"
        var computedHijriYear = "1446"
        var computedHijriDayName = appLanguage == "ar" ? "الجمعة" : "Friday"
        let hijriComponents = hijriCalendar.dateComponents([.day, .month, .year], from: currentDate)
        if let d = hijriComponents.day { computedHijriDay = convertNumbers(String(d), languageCode: appLanguage) }
        if let m = hijriComponents.month { computedHijriMonth = String(m) }
        if let y = hijriComponents.year { computedHijriYear = convertNumbers(String(y), languageCode: appLanguage) }
        let hijriNameFormatter = DateFormatter()
        hijriNameFormatter.calendar = hijriCalendar
        hijriNameFormatter.locale = Locale(identifier: appLanguage)
        hijriNameFormatter.dateFormat = "EEEE"
        computedHijriDayName = hijriNameFormatter.string(from: currentDate)

        // إنشاء PrayerWidgetEntry - Create PrayerWidgetEntry
        return PrayerWidgetEntry(
            date: currentDate,
            fajrName: prayerTimes[0].name, fajrDate: prayerTimes[0].time,
            sunriseName: prayerTimes[1].name, sunriseDate: prayerTimes[1].time,
            dhuhrName: prayerTimes[2].name, dhuhrDate: prayerTimes[2].time,
            asrName: prayerTimes[3].name, asrDate: prayerTimes[3].time,
            maghribName: prayerTimes[4].name, maghribDate: prayerTimes[4].time,
            ishaName: prayerTimes[5].name, ishaDate: prayerTimes[5].time,
            middleOfTheNightName: userDefaults?.string(forKey: "middleOfTheNightName") ?? "منتصف الليل",
            middleOfTheNightDate: monthlyMiddleOfNight ?? convertPrayerTimeToToday(timeString: userDefaults?.string(forKey: "middleOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000"),
            lastThirdOfTheNightName: userDefaults?.string(forKey: "lastThirdOfTheNightName") ?? "ثلث الليل الأخير",
            lastThirdOfTheNightDate: monthlyLastThird ?? convertPrayerTimeToToday(timeString: userDefaults?.string(forKey: "lastThirdOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000"),
            hijriDay: computedHijriDay,
            hijriDayName: computedHijriDayName,
            hijriMonth: computedHijriMonth,
            hijriYear: computedHijriYear,
            nextPrayerDate: nextPrayer?.date ?? Date().addingTimeInterval(3600),
            currentPrayerTime: currentDate,
            appLanguage: appLanguage,
            displaySize: CGSize(width: 300, height: 300),
            prayerTimes: mainPrayers // استخدام الصلوات الخمس فقط - Use only five prayers
        )
    }
}
