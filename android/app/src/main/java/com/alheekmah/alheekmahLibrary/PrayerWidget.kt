package com.alheekmah.alheekmahLibrary

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import android.view.View
import android.content.SharedPreferences
import androidx.core.net.toUri
import es.antonborri.home_widget.HomeWidgetProvider
import com.alheekmah.aqimApp.R
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import android.appwidget.AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
import android.appwidget.AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
import android.graphics.Bitmap
import android.graphics.Canvas
import com.caverock.androidsvg.SVG

open class PrayerWidget : HomeWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return
        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED -> {
                try {
                    val manager = AppWidgetManager.getInstance(context)
                    val component = android.content.ComponentName(context, this::class.java)
                    val ids = manager.getAppWidgetIds(component)
                    if (ids.isNotEmpty()) {
                        val updateIntent = Intent(context, this::class.java).apply {
                            this.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        }
                        context.sendBroadcast(updateIntent)
                    }
                } catch (_: Exception) {}
            }
        }
    }

    // توقيع onUpdate المطلوب من HomeWidgetProvider (يمرّر SharedPreferences مباشرة)
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { id ->
            updateAppWidget(context, appWidgetManager, id, widgetData)
        }
    }

    protected open fun resolveLayout(manager: AppWidgetManager, appWidgetId: Int): Int {
        val options = manager.getAppWidgetOptions(appWidgetId)
        val minW = options.getInt(OPTION_APPWIDGET_MIN_WIDTH)
        val minH = options.getInt(OPTION_APPWIDGET_MIN_HEIGHT)
        val useLarge = (minW >= 250 || minH >= 150)
        return if (useLarge) R.layout.prayer_widget_layout_large else R.layout.prayer_widget_layout_small
    }

    protected open fun updateAppWidget(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val lang = prefs.getString("app_language", "ar") ?: "ar"

        // Hijri values from Flutter (already Arabic digits), with local fallback
        val hijriDay = prefs.getString("hijri_day_number", null) ?: toArabicDigits(getHijriDay().toString(), lang)
        val hijriYear = prefs.getString("hijri_year", null) ?: toArabicDigits(getHijriYear().toString(), lang)
        val hijriMonthIdx = prefs.getString("hijri_month_image", null) ?: "1"
        val dayName = prefs.getString("hijri_day_name", null) ?: weekdayName(Locale(lang))

        val currentPrayerName = prefs.getString("current_prayer_name", null) ?: ""
            val nextPrayerName = (prefs.getString("next_prayer_name", null)
                ?: prefs.getString("althuluth_alakhir_name", null)) ?: ""
        var currentPrayerTime = prefs.getString("current_prayer_time", "--:--") ?: "--:--"
        var nextPrayerTime = prefs.getString("next_prayer_time", "--:--") ?: "--:--"

        // Epochs for countdown (milliseconds since epoch). Add fallback to now to avoid crash.
        var currentEpoch = prefs.getLong("current_prayer_epoch", -1L)
        var nextEpoch = prefs.getLong("next_prayer_epoch", -1L)

        // Fallback: حاول ملء أوقات اليوم من كاش شهري إن وُجد
        if ((currentEpoch <= 0L || nextEpoch <= 0L || nextEpoch <= currentEpoch) ||
            (nextPrayerTime == "--:--")) {
            tryFillFromMonthlyCache(context, prefs)?.let { filled ->
                currentEpoch = filled.currentEpoch
                nextEpoch = filled.nextEpoch
                currentPrayerTime = filled.currentTime ?: currentPrayerTime
                nextPrayerTime = filled.nextTime ?: nextPrayerTime
            }
        }

        val layoutId = resolveLayout(manager, appWidgetId)
        val views = RemoteViews(context.packageName, layoutId)

        // Set layout direction based on app_language (RTL for ar/ur/fa)
        val rtl = isRtlLanguage(lang)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            try {
                views.setInt(R.id.widget_root, "setLayoutDirection", if (rtl) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR)
            } catch (_: Exception) {}
        }

        // Mirror progress bar fill direction for RTL by flipping scaleX
        try {
            views.setFloat(R.id.progress, "setScaleX", if (rtl) -1f else 1f)
        } catch (_: Exception) {}

        // Fill header/date if present (large layout) أو الصغير
        setTextIfExists(context, views, R.id.hijri_day_overlay, hijriDay)
        setTextIfExists(context, views, R.id.hijri_year_weekday, toArabicDigits(hijriYear, lang) + " " + dayName)
        setTextIfExists(context, views, R.id.hijri_day_overlay_small, hijriDay)
        setTextIfExists(context, views, R.id.hijri_year_weekday_small, toArabicDigits(hijriYear, lang) + " " + dayName)
        // Render hijri watermark icon if view exists
        try {
            val assetPath = "flutter_assets/assets/svg/hijri/${hijriMonthIdx}.svg"
            renderSvgAssetToBitmap(context, assetPath, 96f, 54f)?.let {
                views.setImageViewBitmap(R.id.hijri_icon, it)
            }
            renderSvgAssetToBitmap(context, assetPath, 72f, 44f)?.let {
                views.setImageViewBitmap(R.id.hijri_icon_small, it)
            }
        } catch (_: Exception) {}

        // Current / Next (both layouts have next_prayer_name/time in some form)
        setTextIfExists(context, views, R.id.current_prayer_name, currentPrayerName)
            setTextIfExists(context, views, R.id.current_prayer_time, currentPrayerTime)
        setTextIfExists(context, views, R.id.next_prayer_name, nextPrayerName)
        setTextIfExists(context, views, R.id.next_prayer_time, nextPrayerTime)
        setTextIfExists(context, views, R.id.next_prayer_name_big, nextPrayerName)
        setTextIfExists(context, views, R.id.next_prayer_time_big, nextPrayerTime)

        // Removed now_time view per request
        val now = System.currentTimeMillis()

        // Countdown using Chronometer (API 24+ supports countdown flag)
        if (nextEpoch > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val base = SystemClock.elapsedRealtime() + (nextEpoch - System.currentTimeMillis())
            views.setChronometer(R.id.countdown, base, null, true)
            views.setChronometerCountDown(R.id.countdown, true)
            views.setViewVisibility(R.id.countdown, View.VISIBLE)
        } else {
            // Hide countdown when unsupported/unknown
            try { views.setViewVisibility(R.id.countdown, View.GONE) } catch (_: Exception) {}
        }

        // Remaining progress between current and next (100% at start → 0% at next)
        if (currentEpoch > 0 && nextEpoch > 0 && nextEpoch > currentEpoch) {
            val total = nextEpoch - currentEpoch
            val remain = (nextEpoch - now).coerceIn(0L, total)
            val percent = ((remain * 100) / total).toInt().coerceIn(0, 100)
            setProgressIfExists(views, R.id.progress, percent)
        }

        // Fill names/times in large grid if present
        setTextIfExists(context, views, R.id.fajr_name, prefs.getString("fajr_name", "الفجر")?:"الفجر")
        setTextIfExists(context, views, R.id.fajr_time, prefs.getString("fajr_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.fajr_icon, R.drawable.ic_moon)
        setTextIfExists(context, views, R.id.sunrise_name, prefs.getString("shuroq_name", "الشروق")?:"الشروق")
        setTextIfExists(context, views, R.id.sunrise_time, prefs.getString("shuroq_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.sunrise_icon, R.drawable.ic_sun)
        setTextIfExists(context, views, R.id.dhuhr_name, prefs.getString("dhuhr_name", "الظهر")?:"الظهر")
        setTextIfExists(context, views, R.id.dhuhr_time, prefs.getString("dhuhr_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.dhuhr_icon, R.drawable.ic_sun)
        setTextIfExists(context, views, R.id.asr_name, prefs.getString("asr_name", "العصر")?:"العصر")
        setTextIfExists(context, views, R.id.asr_time, prefs.getString("asr_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.asr_icon, R.drawable.ic_sun)
        setTextIfExists(context, views, R.id.maghrib_name, prefs.getString("maghrib_name", "المغرب")?:"المغرب")
        setTextIfExists(context, views, R.id.maghrib_time, prefs.getString("maghrib_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.maghrib_icon, R.drawable.ic_moon)
        setTextIfExists(context, views, R.id.isha_name, prefs.getString("isha_name", "العشاء")?:"العشاء")
        setTextIfExists(context, views, R.id.isha_time, prefs.getString("isha_time", "--:--")?:"--:--")
        setImageResIfExists(views, R.id.isha_icon, R.drawable.ic_moon)

        // Midnight / last third
        setTextIfExists(context, views, R.id.midnight_name, prefs.getString("muntasaf_allayl_name", "منتصف الليل")?:"منتصف الليل")
        setTextIfExists(context, views, R.id.midnight_time, prefs.getString("muntasaf_allayl_time", "--:--")?:"--:--")
        setTextIfExists(context, views, R.id.last_third_name, prefs.getString("althuluth_alakhir_name", "ثلث الليل الأخير")?:"ثلث الليل الأخير")
        setTextIfExists(context, views, R.id.last_third_time, prefs.getString("althuluth_alakhir_time", "--:--")?:"--:--")

        // Highlight NEXT prayer (small layout) ليتطابق مع الكبير
        val nextSmall = nextPrayerName
        setBackgroundIfExists(views, R.id.pill_fajr, if (nextSmall.contains("فجر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.pill_dhuhr, if (nextSmall.contains("ظهر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.pill_asr, if (nextSmall.contains("عصر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.pill_maghrib, if (nextSmall.contains("مغرب")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.pill_isha, if (nextSmall.contains("عشاء")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)

        // Highlight next prayer within rows (large layout)
        val next = nextPrayerName
        setBackgroundIfExists(views, R.id.row_fajr, if (next.contains("فجر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.row_sunrise, if (next.contains("شروق") || next.contains("الشروق")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.row_dhuhr, if (next.contains("ظهر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.row_asr, if (next.contains("عصر")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.row_maghrib, if (next.contains("مغرب")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)
        setBackgroundIfExists(views, R.id.row_isha, if (next.contains("عشاء")) R.drawable.bg_pill_selected else R.drawable.bg_pill_unselected)

        // Click: open app
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setClassName(context.packageName, "com.alheekmah.aqimApp.MainActivity")
            data = "app://open/prayers".toUri()
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("widgetClicked", "PrayerWidget")
        }
        val pending = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        )
        views.setOnClickPendingIntent(R.id.widget_root, pending)

        manager.updateAppWidget(appWidgetId, views)

        // Schedule next automatic update بعد وقت الصلاة القادم + دقيقة لتحديث التمييز
        if (nextEpoch > System.currentTimeMillis()) {
            scheduleNextUpdate(context, appWidgetId, nextEpoch + 60_000) // بعد دقيقة من الأذان
        }
    }

    // نموذج بيانات مساعدة تعبئة من الكاش
    private data class Filled(
        val currentEpoch: Long,
        val nextEpoch: Long,
        val currentTime: String?,
        val nextTime: String?
    )

    // يحاول قراءة كاش شهري مخزّن كسلسلة JSON في SharedPreferences باسم "prayers_month_cache"
    // الصيغة المتوقعة: كائن بمفاتيح على شكل yyyy-MM-dd وقيم: {fajr:"HH:mm", sunrise:"HH:mm", dhuhr:"HH:mm", asr:"HH:mm", maghrib:"HH:mm", isha:"HH:mm"}
    private fun tryFillFromMonthlyCache(context: Context, prefs: SharedPreferences): Filled? {
        return try {
            val json = prefs.getString("prayers_month_cache", null) ?: return null
            val today = java.text.SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(java.util.Date())
            val obj = org.json.JSONObject(json)
            if (!obj.has(today)) return null
            val day = obj.getJSONObject(today)
            val map = mutableMapOf<String, String>()
            for (k in arrayOf("fajr","sunrise","dhuhr","asr","maghrib","isha")) {
                if (day.has(k)) map[k] = day.getString(k)
            }
            if (map.isEmpty()) return null

            fun hhmmToEpoch(hhmm: String): Long {
                val parts = hhmm.split(":")
                val cal = Calendar.getInstance()
                cal.set(Calendar.SECOND, 0)
                cal.set(Calendar.MILLISECOND, 0)
                cal.set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                cal.set(Calendar.MINUTE, parts[1].toInt())
                return cal.timeInMillis
            }

            // جهّز قائمة مرتبة بالأوقات القادمة من الآن
            val now = System.currentTimeMillis()
            val ordered = listOf("fajr","sunrise","dhuhr","asr","maghrib","isha")
                .mapNotNull { k -> map[k]?.let { k to hhmmToEpoch(it) } }
                .sortedBy { it.second }

            if (ordered.isEmpty()) return null

            // حدّد الحالي والقادم ببساطة
            var currentIdx = -1
            for (i in ordered.indices) {
                if (ordered[i].second <= now) currentIdx = i else break
            }
            val nextIdx = (currentIdx + 1).coerceAtMost(ordered.size - 1)
            val currentPair = if (currentIdx >= 0) ordered[currentIdx] else null
            val nextPair = ordered[nextIdx]

            val currentTime = currentPair?.let { toArabicDigits(SimpleDateFormat("HH:mm", Locale.getDefault()).format(java.util.Date(it.second)), prefs.getString("app_language","ar")?:"ar") }
            val nextTime = toArabicDigits(SimpleDateFormat("HH:mm", Locale.getDefault()).format(java.util.Date(nextPair.second)), prefs.getString("app_language","ar")?:"ar")

            Filled(
                currentEpoch = currentPair?.second ?: now,
                nextEpoch = nextPair.second,
                currentTime = currentTime,
                nextTime = nextTime
            )
        } catch (_: Exception) { null }
    }

    private fun getHijriDay(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val cal = android.icu.util.IslamicCalendar()
            cal.get(Calendar.DAY_OF_MONTH)
        } else {
            // Fallback: use Gregorian day to avoid crash on old devices
            Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
        }
    }

    private fun getHijriYear(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val cal = android.icu.util.IslamicCalendar()
            cal.get(Calendar.YEAR)
        } else {
            // Fallback: use Gregorian year
            Calendar.getInstance().get(Calendar.YEAR)
        }
    }

    private fun weekdayName(locale: Locale): String {
        return SimpleDateFormat("EEEE", locale).format(java.util.Date())
    }

    private fun toArabicDigits(input: String, lang: String): String {
        val target = when (lang) {
            "ar", "ur", "fa" -> charArrayOf('٠','١','٢','٣','٤','٥','٦','٧','٨','٩')
            else -> return input
        }
        val sb = StringBuilder(input.length)
        for (ch in input) {
            if (ch in '0'..'9') sb.append(target[ch - '0']) else sb.append(ch)
        }
        return sb.toString()
    }

    private fun formatTime(epochMillis: Long, lang: String): String {
        val locale = Locale(lang)
        val fmt = SimpleDateFormat("HH:mm", locale)
        return toArabicDigits(fmt.format(java.util.Date(epochMillis)), lang)
    }

    private fun isRtlLanguage(lang: String): Boolean {
        return when (lang.lowercase(Locale.ROOT)) {
            "ar", "fa", "ur", "he", "ku" -> true
            else -> false
        }
    }

    private fun setTextIfExists(context: Context, rv: RemoteViews, viewId: Int, text: String) {
        try { rv.setTextViewText(viewId, text) } catch (_: Exception) {}
    }

    private fun setBackgroundIfExists(rv: RemoteViews, viewId: Int, resId: Int) {
        try { rv.setInt(viewId, "setBackgroundResource", resId) } catch (_: Exception) {}
    }

    private fun setProgressIfExists(rv: RemoteViews, viewId: Int, progress: Int) {
        try { rv.setProgressBar(viewId, 100, progress, false) } catch (_: Exception) {}
    }

    private fun setImageResIfExists(rv: RemoteViews, viewId: Int, resId: Int) {
        try { rv.setImageViewResource(viewId, resId) } catch (_: Exception) {}
    }

    private fun dpToPx(context: Context, dp: Float): Int {
        val density = context.resources.displayMetrics.density
        return (dp * density).toInt()
    }

    private fun renderSvgAssetToBitmap(context: Context, assetPath: String, widthDp: Float, heightDp: Float): Bitmap? {
        return try {
            context.assets.open(assetPath).use { input ->
                val svg = SVG.getFromInputStream(input)
                val widthPx = dpToPx(context, widthDp)
                val heightPx = dpToPx(context, heightDp)
                svg.documentWidth = widthPx.toFloat()
                svg.documentHeight = heightPx.toFloat()
                val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                svg.renderToCanvas(canvas)
                bmp
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun scheduleNextUpdate(context: Context, appWidgetId: Int, triggerAtMillis: Long) {
        try {
            val am = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            val intent = Intent(context, this::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            val pending = PendingIntent.getBroadcast(
                context,
                appWidgetId, // استخدام معرف الويدجت لضمان تميّز الإنذار
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                am.setExactAndAllowWhileIdle(android.app.AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
            } else {
                am.setExact(android.app.AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
            }
        } catch (_: Exception) {}
    }
}
