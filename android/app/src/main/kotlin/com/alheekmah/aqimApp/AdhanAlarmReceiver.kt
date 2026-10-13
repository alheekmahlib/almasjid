package com.alheekmah.aqimApp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager

/** يستقبل إنذار وقت الصلاة ويطلق خدمة تشغيل الأذان الأمامية. */
class AdhanAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // الصامت/الاهتزاز يمنعان الأذان (MediaPlayer على قناة الوسائط لا
        // يكتمهما النظام)؛ يظهر إشعار FLN الصامت وحده بلا صوت.
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL) return

        val serviceIntent = Intent(context, AdhanPlaybackService::class.java)
            .putExtra(
                AdhanPlaybackService.EXTRA_FILE_PATH,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_FILE_PATH)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_NOTIF_ID,
                intent.getIntExtra(AdhanPlaybackService.EXTRA_NOTIF_ID, -1)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_NOTIF_TITLE,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_NOTIF_TITLE)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_NOTIF_TEXT,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_NOTIF_TEXT)
            )
            .putExtra(
                AdhanPlaybackService.EXTRA_STOP_ACTION_LABEL,
                intent.getStringExtra(AdhanPlaybackService.EXTRA_STOP_ACTION_LABEL)
            )
        context.startForegroundService(serviceIntent)
    }
}
