package com.alheekmah.aqimApp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** يستقبل إنذار وقت الصلاة ويطلق خدمة تشغيل الأذان الأمامية. */
class AdhanAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val serviceIntent = Intent(context, AdhanPlaybackService::class.java)
            .putExtra(
                AdhanPlaybackService.EXTRA_FILE_PATH,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_FILE_PATH)
            )
        context.startForegroundService(serviceIntent)
    }
}
