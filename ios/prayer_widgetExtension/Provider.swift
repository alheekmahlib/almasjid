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

        // التحقق من وجود البيانات الفردية أولاً - Check for individual data first
        let hasDailyData = userDefaults?.string(forKey: "fajrTime") != nil

        if hasDailyData {
            // استخدام البيانات الفردية (الأحدث) - Use individual data (most recent)
            print("[Widget] Using daily individual prayer times (preferred)")
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
        } else if let monthlyJSONString = userDefaults?.string(forKey: "monthly_prayer_data"),
           let data = monthlyJSONString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dailyTimes = json["dailyTimes"] as? [String: Any] {
            // Fallback للبيانات الشهرية إذا لم تكن البيانات الفردية موجودة
            // Fallback to monthly data if individual data not available
            print("[Widget][Fallback] Using monthly data (no daily data found)")
            let day = calendar.component(.day, from: currentDate)
            if let dayDict = dailyTimes["\(day)"] as? [String: Any] {
                // طباعة القيم الخام لليوم من JSON الشهري قبل أي تحويل
                let rawPairs = dayDict.keys.sorted().map { k -> String in
                    if let v = dayDict[k] { return "\(k)=\(v)" } else { return "\(k)=<nil>" }
                }.joined(separator: ", ")
                print("[Widget][Monthly][RawDay] day=\(day) " + rawPairs)
                // مهيئ محلي للأوقات بدون إزاحة - يدعم 3 أو 6 أرقام للثواني الكسرية
                // Local formatter for times without timezone - supports 3 or 6 fractional digits
                let localFormatter3: DateFormatter = {
                    let f = DateFormatter();
                    f.calendar = Calendar(identifier: .gregorian)
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone.current
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    return f
                }()
                let localFormatter6: DateFormatter = {
                    let f = DateFormatter();
                    f.calendar = Calendar(identifier: .gregorian)
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.timeZone = TimeZone.current
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                    return f
                }()
                let tzRegex = try? NSRegularExpression(pattern: "(Z|[+-]\\d{2}:?\\d{2})$")
                func parse(_ key: String) -> String? {
                    guard let s = dayDict[key] as? String else { return nil }
                    let range = NSRange(location: 0, length: s.utf16.count)
                    let hasTZ = tzRegex?.firstMatch(in: s, options: [], range: range) != nil
                    var d: Date? = nil
                    if hasTZ {
                        d = isoFormatter.date(from: s)
                        if d == nil { print("[Widget][Parse][TZ][Fail] key=\(key) raw=\(s)") }
                    } else {
                        // جرّب التنسيق مع 6 أرقام أولاً، ثم 3 أرقام
                        // Try 6-digit format first, then 3-digit
                        d = localFormatter6.date(from: s)
                        if d == nil {
                            d = localFormatter3.date(from: s)
                        }
                        if d == nil { print("[Widget][Parse][Local][Fail] key=\(key) raw=\(s)") }
                    }
                    guard let dateObj = d else { return nil }
                    let formatted = defaultFormatter.string(from: dateObj)
                    print("[Widget][Parse] key=\(key) raw=\(s) hasTZ=\(hasTZ) used=\(formatted)")
                    return formatted
                }
                let fajr = parse("fajr") ?? "\(currentDateString.prefix(10)) 06:00:00.000"
                let sunrise = parse("sunrise") ?? "\(currentDateString.prefix(10)) 07:00:00.000"
                let dhuhr = parse("dhuhr") ?? "\(currentDateString.prefix(10)) 12:00:00.000"
                let asr = parse("asr") ?? "\(currentDateString.prefix(10)) 15:00:00.000"
                let maghrib = parse("maghrib") ?? "\(currentDateString.prefix(10)) 18:00:00.000"
                let isha = parse("isha") ?? "\(currentDateString.prefix(10)) 19:00:00.000"
                let midnight = parse("midnight") ?? "\(currentDateString.prefix(10)) 00:00:00.000"
                let lastThird = parse("lastThird") ?? "\(currentDateString.prefix(10)) 00:00:00.000"

                let fajrName = userDefaults?.string(forKey: "fajrName") ?? "الفجر"
                let sunriseName = userDefaults?.string(forKey: "sunriseName") ?? "الشروق"
                let dhuhrName = userDefaults?.string(forKey: "dhuhrName") ?? "الظهر"
                let asrName = userDefaults?.string(forKey: "asrName") ?? "العصر"
                let maghribName = userDefaults?.string(forKey: "maghribName") ?? "المغرب"
                let ishaName = userDefaults?.string(forKey: "ishaName") ?? "العشاء"

                prayerTimes = [
                    (name: fajrName, time: fajr),
                    (name: sunriseName, time: sunrise),
                    (name: dhuhrName, time: dhuhr),
                    (name: asrName, time: asr),
                    (name: maghribName, time: maghrib),
                    (name: ishaName, time: isha)
                ]
                mainPrayers = [
                    (name: fajrName, time: fajr),
                    (name: dhuhrName, time: dhuhr),
                    (name: asrName, time: asr),
                    (name: maghribName, time: maghrib),
                    (name: ishaName, time: isha)
                ]

                // Store midnight/lastThird for entry creation
                userDefaults?.set(midnight, forKey: "__monthly_midnight")
                userDefaults?.set(lastThird, forKey: "__monthly_lastThird")
            }
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

        // حساب بدائل التاريخ الهجري محليًا عند غياب بيانات التطبيق - Compute Hijri fallbacks locally if app data missing
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
            middleOfTheNightDate: (userDefaults?.string(forKey: "__monthly_midnight")
                                   ?? convertPrayerTimeToToday(timeString: userDefaults?.string(forKey: "middleOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000")),
            lastThirdOfTheNightName: userDefaults?.string(forKey: "lastThirdOfTheNightName") ?? "ثلث الليل الأخير",
            lastThirdOfTheNightDate: (userDefaults?.string(forKey: "__monthly_lastThird")
                                     ?? convertPrayerTimeToToday(timeString: userDefaults?.string(forKey: "lastThirdOfTheNightTime") ?? "\(currentDateString.prefix(10)) 00:00:00.000")),
            hijriDay: convertNumbers(userDefaults?.string(forKey: "hijriDay") ?? fallbackHijriDay, languageCode: appLanguage),
            hijriDayName: userDefaults?.string(forKey: "hijriDayName") ?? fallbackHijriDayName,
            hijriMonth: userDefaults?.string(forKey: "hijriMonth") ?? fallbackHijriMonth,
            hijriYear: convertNumbers(userDefaults?.string(forKey: "hijriYear") ?? fallbackHijriYear, languageCode: appLanguage),
            nextPrayerDate: nextPrayer?.date ?? Date().addingTimeInterval(3600),
            currentPrayerTime: currentDate,
            appLanguage: appLanguage,
            displaySize: CGSize(width: 300, height: 300),
            prayerTimes: mainPrayers // استخدام الصلوات الخمس فقط - Use only five prayers
        )
    }
}
