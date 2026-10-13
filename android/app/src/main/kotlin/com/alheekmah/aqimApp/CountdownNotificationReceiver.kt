package com.alheekmah.aqimApp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * يستقبل منبّهات حدود الصلوات وأحداث النظام لإشعار العدّ التنازلي الدائم:
 * - ACTION_BOUNDARY: حدّ صلاة — انشر نصّه وسلّح التالي.
 * - الإقلاع/تغيير الوقت أو المنطقة الزمنية أو اللغة: إعادة نشر وتسليح.
 */
class CountdownNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            PrayerCountdownNotifier.ACTION_BOUNDARY -> {
                val index = intent.getIntExtra(PrayerCountdownNotifier.EXTRA_INDEX, -1)
                if (index >= 0) {
                    PrayerCountdownNotifier.onBoundary(context, index)
                } else {
                    PrayerCountdownNotifier.onSystemEvent(context)
                }
            }
            else -> {
                // BOOT_COMPLETED / TIME_SET / TIMEZONE_CHANGED / DATE_CHANGED / LOCALE_CHANGED
                PrayerCountdownNotifier.onSystemEvent(context)
            }
        }
    }
}
