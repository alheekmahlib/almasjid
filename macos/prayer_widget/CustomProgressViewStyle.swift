//
//  CustomProgressViewStyle.swift
//  prayer_widget
//

import SwiftUI

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
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backColor ?? Color.white)
                        .frame(height: barHeight)

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
