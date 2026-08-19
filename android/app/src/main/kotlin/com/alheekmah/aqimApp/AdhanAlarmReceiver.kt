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
            .putExtra(
                AdhanPlaybackService.EXTRA_NOTIFICATION_TITLE,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_NOTIFICATION_TITLE)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_NOTIFICATION_TEXT,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_NOTIFICATION_TEXT)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_STOP_ACTION_LABEL,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_STOP_ACTION_LABEL)
            )
        context.startForegroundService(serviceIntent)
    }
}
