import ActivityKit
import SwiftUI
import WidgetKit

struct PrayerCountdownAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var nextName: String
        var nextAt: Date
        var nextTimeText: String
        var prevName: String
        var prevAt: Date
    }

    var nextLabel: String
    var elapsedLabel: String
}

private func countdownRange(to target: Date) -> ClosedRange<Date> {
    let now = Date()
    return now...max(now, target)
}

private func elapsedRange(since start: Date, until end: Date) -> ClosedRange<Date> {
  let now = Date()
  let from = min(now, start)
  return from...max(from, end)
}

// MARK: - Almasjid Colors

private extension Color {
    static let aqimDeepTeal = Color(
        red: 0x00 / 255.0,
        green: 0x1A / 255.0,
        blue: 0x23 / 255.0
    )

    static let aqimGreen = Color(
        red: 0x7A / 255.0,
        green: 0x9E / 255.0,
        blue: 0x7E / 255.0
    )

    static let aqimWhite = Color(
        red: 0xEF / 255.0,
        green: 0xF4 / 255.0,
        blue: 0xFE / 255.0
    )
}

// MARK: - Prayer Icon

private struct PrayerIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.aqimGreen.opacity(0.16))

            Image(systemName: "moon.stars.fill")
                .font(
                    .system(
                        size: size * 0.42,
                        weight: .semibold
                    )
                )
                .foregroundStyle(Color.aqimGreen)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Live Activity

@available(iOS 17.0, *)
struct PrayerLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: PrayerCountdownAttributes.self
        ) { context in

            lockScreenView(context: context)
                .activityBackgroundTint(Color.aqimDeepTeal)
                .activitySystemActionForegroundColor(Color.aqimWhite)

        } dynamicIsland: { context in

            DynamicIsland {

                // MARK: Expanded - Leading

                DynamicIslandExpandedRegion(.leading) {
                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.aqimGreen)
                                .frame(
                                    width: 6,
                                    height: 6
                                )

                            Text(context.attributes.nextLabel)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(
                                    Color.aqimWhite.opacity(0.62)
                                )
                        }

                        Text(context.state.nextName)
                            .font(
                                .system(
                                    size: 17,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(Color.aqimWhite)

                        Text(
                            timerInterval: countdownRange(
                                to: context.state.nextAt
                            ),
                            countsDown: true
                        )
                        .font(
                            .system(
                                size: 21,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .monospacedDigit()
                        .foregroundStyle(Color.aqimGreen)
                    }
                }

                // MARK: Expanded - Trailing

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(
                        alignment: .trailing,
                        spacing: 5
                    ) {
                        Text(context.attributes.elapsedLabel)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(
                                Color.aqimWhite.opacity(0.55)
                            )

                        Text(context.state.prevName)
                            .font(
                                .system(
                                    size: 15,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(
                                Color.aqimWhite.opacity(0.9)
                            )

                        Text(
                            timerInterval: elapsedRange(
                                since: context.state.prevAt,
                                until: context.state.nextAt
                            ),
                            countsDown: false
                        )
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .monospacedDigit()
                        .foregroundStyle(
                            Color.aqimWhite.opacity(0.72)
                        )
                    }
                }

                // MARK: Expanded - Bottom

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(
                                Color.aqimGreen.opacity(0.35)
                            )
                            .frame(height: 1)

                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(
                                Color.aqimGreen.opacity(0.8)
                            )

                        Rectangle()
                            .fill(
                                Color.aqimGreen.opacity(0.35)
                            )
                            .frame(height: 1)
                    }
                    .padding(.top, 4)
                }

            } compactLeading: {

                PrayerIcon(size: 24)

            } compactTrailing: {

                Text(
                    timerInterval: countdownRange(
                        to: context.state.nextAt
                    ),
                    countsDown: true
                )
                .font(
                    .system(
                        size: 13,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .foregroundStyle(Color.aqimGreen)
                .frame(minWidth: 48)

            } minimal: {

                ZStack {
                    Circle()
                        .fill(
                            Color.aqimGreen.opacity(0.16)
                        )

                    Image(systemName: "moon.stars.fill")
                        .font(
                            .system(
                                size: 11,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(Color.aqimGreen)
                }
                .frame(
                    width: 22,
                    height: 22
                )
            }
        }
    }

    // MARK: - Lock Screen

    @ViewBuilder
    private func lockScreenView(
        context: ActivityViewContext<PrayerCountdownAttributes>
    ) -> some View {

        VStack(spacing: 0) {

            // Header

            HStack(spacing: 9) {

                PrayerIcon(size: 32)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text(context.attributes.nextLabel)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(
                            Color.aqimWhite.opacity(0.58)
                        )

                    Text(context.state.nextName)
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(Color.aqimWhite)
                }

                Spacer()

                Text(context.state.nextTimeText)
                    .font(
                        .system(
                            size: 15,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(
                        Color.aqimWhite.opacity(0.78)
                    )
            }

            // Countdown

            HStack(
                alignment: .firstTextBaseline,
                spacing: 8
            ) {

                Text(
                    timerInterval: countdownRange(
                        to: context.state.nextAt
                    ),
                    countsDown: true
                )
                .font(
                    .system(
                        size: 34,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .foregroundStyle(Color.aqimGreen)

                Spacer()
            }
            .padding(.top, 12)

            // Divider

            HStack(spacing: 8) {

                Rectangle()
                    .fill(
                        Color.aqimWhite.opacity(0.08)
                    )
                    .frame(height: 1)

                Circle()
                    .fill(
                        Color.aqimGreen.opacity(0.7)
                    )
                    .frame(
                        width: 4,
                        height: 4
                    )

                Rectangle()
                    .fill(
                        Color.aqimWhite.opacity(0.08)
                    )
                    .frame(height: 1)
            }
            .padding(.vertical, 11)

            // Previous Prayer

            HStack(spacing: 8) {

                Image(
                    systemName: "checkmark.circle.fill"
                )
                .font(.system(size: 13))
                .foregroundStyle(
                    Color.aqimGreen.opacity(0.8)
                )

                Text(context.state.prevName)
                    .font(
                        .caption.weight(.medium)
                    )
                    .foregroundStyle(
                        Color.aqimWhite.opacity(0.72)
                    )

                Text("·")
                    .foregroundStyle(
                        Color.aqimWhite.opacity(0.3)
                    )

                Text(
                    timerInterval: elapsedRange(
                        since: context.state.prevAt,
                        until: context.state.nextAt
                    ),
                    countsDown: false
                )
                .font(
                    .system(
                        size: 14,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .foregroundStyle(
                    Color.aqimWhite.opacity(0.62)
                )

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
