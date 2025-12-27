//
//  prayer_widgetExtension.swift
//  prayer_widgetExtension
//
//  Created by Hawazen Mahmood on 11/15/25.
//

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

struct prayer_widgetExtensionEntryView : View {
    var entry: Provider.Entry
    let brown = Color(hex: "001A23")
    let lightBrown = Color(hex: "7A9E7E")
    // استخدام SF Symbol بدلاً من الصورة المخصصة لتجنب مشكلة الحجم - Use SF Symbol instead of custom image to avoid size issue
    let logoImg = Image("aqem_logo_stroke")

    @Environment(\.widgetFamily) var widgetFamily

    var layoutDirection: LayoutDirection {
        return entry.appLanguage == "ar" ? .rightToLeft : .leftToRight
    }

    var progress: Double {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)

        guard let currentPrayer = prayerTimesResult.0,
              let nextPrayer = prayerTimesResult.1 else {
            print("الصلاة الحالية أو القادمة غير موجودة")
            return 0.0
        }

        let totalInterval = nextPrayer.date.timeIntervalSince(currentPrayer.date)
        let elapsedInterval = currentTime.timeIntervalSince(currentPrayer.date)

        let calculatedProgress = max(0, min(elapsedInterval / totalInterval, 1))
        print("الصلاة الحالية: \(currentPrayer.name) - \(currentPrayer.date)")
        print("الصلاة القادمة: \(nextPrayer.name) - \(nextPrayer.date)")
        print("Progress calculated: \(calculatedProgress)")

        return calculatedProgress
    }

    var currentPrayer: String {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)
        
        if let currentPrayer = prayerTimesResult.0 {
            return currentPrayer.name
        }
        
        // الطريقة التقليدية كـ fallback
        if let fajrTime = convertToTime(from: entry.fajrDate),
            let dhuhrTime = convertToTime(from: entry.dhuhrDate),
            let asrTime = convertToTime(from: entry.asrDate),
            let maghribTime = convertToTime(from: entry.maghribDate),
            let ishaTime = convertToTime(from: entry.ishaDate)
        {

            if currentTime >= fajrTime && currentTime < dhuhrTime {
                return entry.fajrName
            } else if currentTime >= dhuhrTime && currentTime < asrTime {
                return entry.dhuhrName
            } else if currentTime >= asrTime && currentTime < maghribTime {
                return entry.asrName
            } else if currentTime >= maghribTime && currentTime < ishaTime {
                return entry.maghribName
            } else {
                return entry.ishaName
            }
        }

        return "Unknown"
    }

    var currentPrayerTime: String {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)
        
        if let currentPrayer = prayerTimesResult.0 {
            // تحويل التاريخ إلى نص - Convert date to string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: currentPrayer.date)
        }
        
        // الطريقة التقليدية كـ fallback
        if let fajrTime = convertToTime(from: entry.fajrDate),
            let dhuhrTime = convertToTime(from: entry.dhuhrDate),
            let asrTime = convertToTime(from: entry.asrDate),
            let maghribTime = convertToTime(from: entry.maghribDate),
            let ishaTime = convertToTime(from: entry.ishaDate)
        {

            if currentTime >= fajrTime && currentTime < dhuhrTime {
                return entry.fajrDate
            } else if currentTime >= dhuhrTime && currentTime < asrTime {
                return entry.dhuhrDate
            } else if currentTime >= asrTime && currentTime < maghribTime {
                return entry.asrDate
            } else if currentTime >= maghribTime && currentTime < ishaTime {
                return entry.maghribDate
            } else {
                return entry.ishaDate
            }
        }

        return "0:00"
    }

    var nextPrayer: String {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)
        
        // طباعة الصلوات المستخدمة للتحقق - Print prayers used for verification
        print("entry.prayerTimes في nextPrayer: \(entry.prayerTimes)")
        
        if let nextPrayer = prayerTimesResult.1 {
            print("الصلاة القادمة المحسوبة: \(nextPrayer.name)")
            return nextPrayer.name
        }
        
        // الطريقة التقليدية كـ fallback
        if let fajrTime = convertToTime(from: entry.fajrDate),
            let dhuhrTime = convertToTime(from: entry.dhuhrDate),
            let asrTime = convertToTime(from: entry.asrDate),
            let maghribTime = convertToTime(from: entry.maghribDate),
            let ishaTime = convertToTime(from: entry.ishaDate)
        {

            if currentTime >= ishaTime || currentTime < fajrTime {
                // إذا كان الوقت بعد العشاء أو قبل الفجر
                return entry.fajrName
            } else if currentTime >= maghribTime && currentTime < ishaTime {
                return entry.ishaName
            } else if currentTime >= asrTime && currentTime < maghribTime {
                return entry.maghribName
            } else if currentTime >= dhuhrTime && currentTime < asrTime {
                return entry.asrName
            } else if currentTime >= fajrTime && currentTime < dhuhrTime {
                return entry.dhuhrName
            }
        }

        return "Unknown"
    }

    var nextPrayerTime: String {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)
        
        if let nextPrayer = prayerTimesResult.1 {
            // تحويل التاريخ إلى نص - Convert date to string
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: nextPrayer.date)
        }
        
        // الطريقة التقليدية كـ fallback
        if let fajrTime = convertToTime(from: entry.fajrDate),
            let dhuhrTime = convertToTime(from: entry.dhuhrDate),
            let asrTime = convertToTime(from: entry.asrDate),
            let maghribTime = convertToTime(from: entry.maghribDate),
            let ishaTime = convertToTime(from: entry.ishaDate)
        {

            if currentTime >= ishaTime || currentTime < fajrTime {
                return entry.fajrDate
            } else if currentTime >= maghribTime && currentTime < ishaTime {
                return entry.ishaDate
            } else if currentTime >= asrTime && currentTime < maghribTime {
                return entry.maghribDate
            } else if currentTime >= dhuhrTime && currentTime < asrTime {
                return entry.asrDate
            } else if currentTime >= fajrTime && currentTime < dhuhrTime {
                return entry.dhuhrDate
            }
        }

        return "0:00"
    }

    var nextPrayerIcons: String {
        // استخدام التاريخ من الـ entry للحصول على أحدث قيمة - Use entry date to get latest value
        let currentTime = entry.date

        if let fajrTime = convertToTime(from: entry.fajrDate),
            let dhuhrTime = convertToTime(from: entry.dhuhrDate),
            let asrTime = convertToTime(from: entry.asrDate),
            let maghribTime = convertToTime(from: entry.maghribDate),
            let ishaTime = convertToTime(from: entry.ishaDate)
        {

            if currentTime >= ishaTime || currentTime < fajrTime {
                // إذا كان الوقت بعد العشاء أو قبل الفجر
                return "moon.haze.fill"
            } else if currentTime >= maghribTime && currentTime < ishaTime {
                return "moon.fill"
            } else if currentTime >= asrTime && currentTime < maghribTime {
                return "sunset.fill"
            } else if currentTime >= dhuhrTime && currentTime < asrTime {
                return "sun.max.fill"
            } else if currentTime >= fajrTime && currentTime < dhuhrTime {
                return "moon.haze.fill"
            }
        }

        return "moon.haze.fill"
    }

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            case .systemLarge:
                largeWidgetView
            case .accessoryRectangular:
                lockScreenWidgetView
            case .accessoryCircular:
                lockScreenCircularWidgetView
            case .accessoryInline:
                lockScreenInlineWidgetView
            default:
                mediumWidgetView  // الافتراضي
            }
        }
        .environment(\.layoutDirection, layoutDirection)  // ضبط الاتجاه بناءً على اللغة
    }

    var lockScreenInlineWidgetView: some View {
        HStack {
            Text(nextPrayer)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
            Image(systemName: nextPrayerIcons)
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.white.opacity(0.2))
            Text(
                TimeOnly(
                    from: nextPrayerTime,
                    languageCode: entry.appLanguage) ?? "0:00"
            )
        }
        .frame(width: 70, alignment: .center)
        .widgetBackground(backgroundView: brown)
    }

    var lockScreenCircularWidgetView: some View {
        ZStack {
            Image(systemName: nextPrayerIcons)
                .font(.system(size: 30, weight: .light))
                .foregroundColor(.white.opacity(0.2))
            VStack {
                Text(nextPrayer)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                Text(
                    TimeOnly(
                        from: nextPrayerTime,
                        languageCode: entry.appLanguage) ?? "0:00"
                )
            }
        }
        .frame(width: 70, alignment: .center)
        .widgetBackground(backgroundView: brown)
    }

    var lockScreenWidgetView: some View {
        ZStack {
            HStack {
                ZStack {
                    Image(systemName: nextPrayerIcons)
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.white.opacity(0.2))
                    Text(nextPrayer)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .frame(alignment: .center)
                        .multilineTextAlignment(.center)
                }
                HStack {
                    Text(entry.nextPrayerDate, style: .timer)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .frame(height: 20, alignment: .center)
                        .environment(\.locale, Locale(identifier: entry.appLanguage))
                }
            }
            ProgressView(value: progress)
                .progressViewStyle(
                    CustomProgressViewStyle(
                        tintColor: .black,
                        backColor: Color.white,
                        barHeight: 7,
                        barHeight2: 5,
                        nextPrayerDate: entry.nextPrayerDate,
                        showTimer: false,
                        appLanguage: entry.appLanguage)
                )
                .frame(width: 150, height: 70, alignment: .bottom)
        }
        .padding()
        .frame(width: 150, alignment: .center)
        .widgetBackground(backgroundView: brown)
    }

    var smallWidgetView: some View {
        VStack {
            ZStack {
                Image(systemName: nextPrayerIcons)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white.opacity(0.2))
                VStack {
                    Text(nextPrayer)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .frame(alignment: .center)
                        .multilineTextAlignment(.center)
                    Text(
                        TimeOnly(
                            from: nextPrayerTime,
                            languageCode: entry.appLanguage) ?? "0:00"
                    )
                    .frame(alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                }
            }
            localizedTimerView(
                to: entry.nextPrayerDate)
            ProgressView(value: progress)
                .progressViewStyle(
                    CustomProgressViewStyle(
                        tintColor: brown,
                        backColor: lightBrown,
                        barHeight: 10,
                        barHeight2: 8,
                        nextPrayerDate: entry.nextPrayerDate,
                        showTimer: false,
                        appLanguage: entry.appLanguage)
                )
                .frame(width: 140, alignment: .center)
        }
        .padding()
        .cornerRadius(16)
        .frame(
            width: entry.displaySize.width,
            height: entry.displaySize.height, alignment: .center
        )
        .widgetBackground(backgroundView: brown)
    }

    var mediumWidgetView: some View {
        VStack {
                HStack {
                    HStack {
                        Image(systemName: nextPrayerIcons)
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(.white)
                        VStack {
                            Text(nextPrayer)
                                .foregroundColor(.white)
                                .font(
                                    .system(
                                        size: 20, weight: .bold, design: .serif)
                                )
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                            Text(
                                TimeOnly(
                                    from: nextPrayerTime,
                                    languageCode: entry.appLanguage) ?? "0:00"
                            )
                            .frame(alignment: .center)
                            .foregroundColor(.white)
                            .font(
                                .system(size: 18, weight: .bold, design: .serif)
                            )
                        }

                    }
                    .frame(width: 160, alignment: .center)
                    localizedTimerView(
                        to: entry.nextPrayerDate)
                }
                .frame(height: 50, alignment: .center)
            HStack {
                prayerView(name: entry.fajrName, time: entry.fajrDate)
                prayerView(name: entry.dhuhrName, time: entry.dhuhrDate)
                prayerView(name: entry.asrName, time: entry.asrDate)
                prayerView(name: entry.maghribName, time: entry.maghribDate)
                prayerView(name: entry.ishaName, time: entry.ishaDate)
            }
            .padding(.horizontal, 8)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .gray.opacity(0.3), radius: 7, x: 0, y: -7)
        ZStack {
            ProgressView(value: progress)
                .progressViewStyle(
                    CustomProgressViewStyle(
                        tintColor: brown,
                        backColor: lightBrown,
                        barHeight: 25,
                        barHeight2: 22,
                        nextPrayerDate: entry.nextPrayerDate,
                        showTimer: false,
                        appLanguage: entry.appLanguage
                    )
                )  // يمكنك زيادة قيمة barHeight
                .frame(width: 300)  // تحديد العرض فقط
                .padding(0)
            logoImg
                .resizable()
                .frame(width: 30, height: 15, alignment: .center)
                .padding(.top, 4)
                .padding(.bottom, 4)
        }
        .padding(.top, 4)
        }
        .frame(
            width: entry.displaySize.width,
            height: entry.displaySize.height
        )
        .widgetBackground(backgroundView: brown)
    }

    var largeWidgetView: some View {
        VStack {
            HStack{
                VStack {
                        ZStack {
                            Image(entry.hijriMonth)
                                .frame(width: 85, height: 25, alignment: .center)
                                .opacity(0.2)
                            Text(entry.hijriDay)
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .bold, design: .serif))
                        }
                        HStack {
                            Text(entry.hijriDayName)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                            Text(entry.hijriYear)
                                .frame(alignment: .center)
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                        }
                    }
                    .frame(alignment: .center)
                Spacer()
                ZStack {
                    Image(systemName: nextPrayerIcons)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white.opacity(0.2))
                    VStack {
                        Text(nextPrayer)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Text(
                            TimeOnly(
                                from: nextPrayerTime,
                                languageCode: entry.appLanguage) ?? "0:00"
                        )
                        .frame(alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                    }
                }
            }

            VStack {
                ProgressView(value: progress)
                    .progressViewStyle(
                        CustomProgressViewStyle(
                            tintColor: brown,
                            backColor: lightBrown,
                            barHeight: 35,
                            barHeight2: 30,
                            nextPrayerDate: entry.nextPrayerDate,
                            showTimer: true,
                            appLanguage: entry.appLanguage
                        )
                    )
                    .frame(width: 300)
                HStack {
                    VStack {
                        hPrayerView(
                            name: entry.fajrName, time: entry.fajrDate,
                            fontSize: 16)
                        hPrayerView(
                            name: entry.sunriseName, time: entry.sunriseDate,
                            fontSize: 16)
                        hPrayerView(
                            name: entry.dhuhrName, time: entry.dhuhrDate,
                            fontSize: 16)
                        hPrayerView(
                            name: entry.asrName, time: entry.asrDate,
                            fontSize: 16)
                    }
                    VStack {
                        hPrayerView(
                            name: entry.maghribName, time: entry.maghribDate,
                            fontSize: 16)
                        hPrayerView(
                            name: entry.ishaName, time: entry.ishaDate,
                            fontSize: 16)
                        hPrayerView(
                            name: entry.middleOfTheNightName,
                            time: entry.middleOfTheNightDate, fontSize: 14)
                        hPrayerView(
                            name: entry.lastThirdOfTheNightName,
                            time: entry.lastThirdOfTheNightDate, fontSize: 14)
                    }
                }
                .padding(8)
            }
            logoImg
                .resizable()
                .frame(width: 40, height: 20, alignment: .center)
                .padding(.top, 4)
                .padding(.bottom, 4)
        }
        .cornerRadius(16)
        .frame(
            width: entry.displaySize.width,
            height: entry.displaySize.height
        )
        .widgetBackground(backgroundView: brown)
    }

    @ViewBuilder
    func prayerView(name: String, time: String) -> some View {
        VStack {
            Text(name)
                .frame(width: 60, alignment: .center)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .light, design: .serif))
            Text(
                TimeOnly(from: time, languageCode: entry.appLanguage) ?? "0:00"
            )
            .frame(width: 60, height: 20, alignment: .center)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .light, design: .serif))
        }
        .padding(0)
        .background(
            nextPrayer == name ? lightBrown : Color.clear
        )
        .cornerRadius(4)
    }

    @ViewBuilder
    func hPrayerView(name: String, time: String, fontSize: CGFloat) -> some View
    {
        HStack {
            Text(name)
                .frame(width: 80, height: 20, alignment: .center)
                .foregroundColor(.white)
                .font(.system(size: fontSize, weight: .light, design: .serif))
            Text(
                TimeOnly(from: time, languageCode: entry.appLanguage) ?? "0:00"
            )
            .frame(width: 70, height: 20, alignment: .center)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .light, design: .serif))
        }
        .padding(4)
        .background(
            nextPrayer == name ? lightBrown : Color.clear
        )
        .cornerRadius(4)
    }

    @ViewBuilder
    func localizedTimerView(to nextPrayerDate: Date) -> some View {
        HStack {
            Text(nextPrayerDate, style: .timer)
                .foregroundColor(.white)
                .font(.title)
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .frame(height: 30, alignment: .center)
                .environment(\.locale, Locale(identifier: entry.appLanguage))
        }
    }
}

struct NumberLocalizationModifier: ViewModifier {
    let languageCode: String

    func body(content: Content) -> some View {
        content.onChange(of: Locale.current.language.languageCode?.identifier) {
            _ in
            // تنسيق الرقم حسب اللغة
        }
        .environment(\.locale, .init(identifier: languageCode))
    }
}

struct prayer_widget: Widget {
    // تحذير: لا تُغيّر هذه القيمة! تغييرها يحذف الـ widget من شاشات المستخدمين
    // WARNING: Do NOT change this value! Changing it removes the widget from users' screens
    let kind: String = "prayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            prayer_widgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("أوقات الصلاة")
        .description("ابقَ على اطلاع بمواقيت الصلاة اليومية بدقة مع تحديث تلقائي حسب موقعك.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular, .accessoryInline
        ])
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0,
        macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    var tintColor: Color
    var backColor: Color? = nil
    var barHeight: CGFloat
    var barHeight2: CGFloat
    var nextPrayerDate: Date? = nil
    var showTimer: Bool = false
    var appLanguage: String = "ar"
    
    @ViewBuilder
    func localizedTimerView(to nextPrayerDate: Date) -> some View {
        HStack {
            Text(nextPrayerDate, style: .timer)
                .foregroundColor(.white)
                .font(.title)
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .frame(height: 30, alignment: .center)
                .environment(\.locale, Locale(identifier: appLanguage))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .leading) {
                    // الخلفية
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backColor ?? Color.white)
                        .frame(height: barHeight)
                    
                    // الشريط الملون (progress tint)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tintColor)
                        .frame(
                            width: geometry.size.width
                            * CGFloat(configuration.fractionCompleted ?? 0),
                            height: barHeight2
                        )
                        .padding(2)
                }
                if showTimer, let nextPrayerDate = nextPrayerDate {
                    localizedTimerView(to: nextPrayerDate)
                }
            }
        }
        .frame(height: barHeight)
    }
}

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

