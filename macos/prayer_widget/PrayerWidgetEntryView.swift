//
//  PrayerWidgetEntryView.swift
//  prayer_widget
//

import WidgetKit
import SwiftUI

enum SmallWidgetLayoutMode {
    case standard
    case fajr
}

struct prayer_widgetExtensionEntryView : View {
    var entry: Provider.Entry
    var smallLayout: SmallWidgetLayoutMode = .standard
    let brown = Color(hex: "001A23")
    let lightBrown = Color(hex: "7A9E7E")
    let logoImg = Image("aqem_logo_stroke")

    @Environment(\.widgetFamily) var widgetFamily

    var layoutDirection: LayoutDirection {
        return entry.appLanguage == "ar" ? .rightToLeft : .leftToRight
    }

    var progress: Double {
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

    private func clampedProgress(start: Date, end: Date, now: Date) -> Double {
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 0.0 }
        let elapsed = now.timeIntervalSince(start)
        return max(0.0, min(elapsed / total, 1.0))
    }

    var fajrProgress: Double {
        let now = entry.date
        guard let fajrTimeToday = convertToTime(from: entry.fajrDate) else {
            return 0.0
        }

        let calendar = Calendar.current

        if now >= fajrTimeToday {
            let nextFajr = calendar.date(byAdding: .day, value: 1, to: fajrTimeToday) ?? fajrTimeToday
            return clampedProgress(start: fajrTimeToday, end: nextFajr, now: now)
        } else {
            let previousFajr = calendar.date(byAdding: .day, value: -1, to: fajrTimeToday) ?? fajrTimeToday
            return clampedProgress(start: previousFajr, end: fajrTimeToday, now: now)
        }
    }

    var maghribProgress: Double {
        let now = entry.date
        guard let maghribTimeToday = convertToTime(from: entry.maghribDate) else {
            return 0.0
        }

        let calendar = Calendar.current

        if now >= maghribTimeToday {
            let nextMaghrib = calendar.date(byAdding: .day, value: 1, to: maghribTimeToday) ?? maghribTimeToday
            return clampedProgress(start: maghribTimeToday, end: nextMaghrib, now: now)
        } else {
            let previousMaghrib = calendar.date(byAdding: .day, value: -1, to: maghribTimeToday) ?? maghribTimeToday
            return clampedProgress(start: previousMaghrib, end: maghribTimeToday, now: now)
        }
    }

    var currentPrayer: String {
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)

        if let currentPrayer = prayerTimesResult.0 {
            return currentPrayer.name
        }

        if let fajrTime = convertToTime(from: entry.fajrDate),
           let dhuhrTime = convertToTime(from: entry.dhuhrDate),
           let asrTime = convertToTime(from: entry.asrDate),
           let maghribTime = convertToTime(from: entry.maghribDate),
           let ishaTime = convertToTime(from: entry.ishaDate) {

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
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)

        if let currentPrayer = prayerTimesResult.0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: currentPrayer.date)
        }

        if let fajrTime = convertToTime(from: entry.fajrDate),
           let dhuhrTime = convertToTime(from: entry.dhuhrDate),
           let asrTime = convertToTime(from: entry.asrDate),
           let maghribTime = convertToTime(from: entry.maghribDate),
           let ishaTime = convertToTime(from: entry.ishaDate) {

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
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)

        print("entry.prayerTimes في nextPrayer: \(entry.prayerTimes)")

        if let nextPrayer = prayerTimesResult.1 {
            print("الصلاة القادمة المحسوبة: \(nextPrayer.name)")
            return nextPrayer.name
        }

        if let fajrTime = convertToTime(from: entry.fajrDate),
           let dhuhrTime = convertToTime(from: entry.dhuhrDate),
           let asrTime = convertToTime(from: entry.asrDate),
           let maghribTime = convertToTime(from: entry.maghribDate),
           let ishaTime = convertToTime(from: entry.ishaDate) {

            if currentTime >= ishaTime || currentTime < fajrTime {
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
        let currentTime = entry.date
        let prayerTimesResult = getPrayerTimesForProgress(currentTime: currentTime, prayerTimes: entry.prayerTimes)

        if let nextPrayer = prayerTimesResult.1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: nextPrayer.date)
        }

        if let fajrTime = convertToTime(from: entry.fajrDate),
           let dhuhrTime = convertToTime(from: entry.dhuhrDate),
           let asrTime = convertToTime(from: entry.asrDate),
           let maghribTime = convertToTime(from: entry.maghribDate),
           let ishaTime = convertToTime(from: entry.ishaDate) {

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

    var fajrPrayerTime: String {
        if let fajrDate = convertToTime(from: entry.fajrDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: fajrDate)
        }
        return entry.fajrDate
    }

    var maghribPrayerTime: String {
        if let maghribDate = convertToTime(from: entry.maghribDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: maghribDate)
        }
        return entry.maghribDate
    }

    var nextPrayerIcons: String {
        let currentTime = entry.date

        if let fajrTime = convertToTime(from: entry.fajrDate),
           let dhuhrTime = convertToTime(from: entry.dhuhrDate),
           let asrTime = convertToTime(from: entry.asrDate),
           let maghribTime = convertToTime(from: entry.maghribDate),
           let ishaTime = convertToTime(from: entry.ishaDate) {

            if currentTime >= ishaTime || currentTime < fajrTime {
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
            default:
                mediumWidgetView
            }
        }
        .environment(\.layoutDirection, layoutDirection)
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
                    )
                    .frame(width: 300)
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
            .frame(width: 300)

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
    func hPrayerView(name: String, time: String, fontSize: CGFloat) -> some View {
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
        content.onChange(of: Locale.current.language.languageCode?.identifier) { _ in
            // تنسيق الرقم حسب اللغة
        }
        .environment(\.locale, .init(identifier: languageCode))
    }
}
