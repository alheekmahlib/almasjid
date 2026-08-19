package com.alheekmah.aqimApp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import java.io.File

/**
 * خدمة أمامية (mediaPlayback) تشغّل الأذان كاملاً عند وقت الصلاة.
 * مصدر الصوت: ملف محمّل من الكتالوج إن وُجد، وإلا المورد الخام الافتراضي.
 */
class AdhanPlaybackService : Service() {

    companion object {
        const val EXTRA_FILE_PATH = "filePath"

        /// نصوص إشعار الخدمة المترجمة، تُمرَّر من Flutter وقت الجدولة.
        const val EXTRA_NOTIFICATION_TITLE = "notificationTitle"
        const val EXTRA_NOTIFICATION_TEXT = "notificationText"
        const val EXTRA_STOP_ACTION_LABEL = "stopActionLabel"
        const val ACTION_STOP = "com.alheekmah.aqimApp.ACTION_STOP_ADHAN"
        const val CHANNEL_ID = "adhan_playback_channel"
        const val NOTIFICATION_ID = 30001

        /** المورد الخام الافتراضي عند غياب ملف محمّل (الأقصى). */
        const val DEFAULT_RAW_NAME = "aqsa_athan"

        /** احتياط عربي إن لم تصل النصوص المترجمة (إنذارات قديمة مثلاً). */
        const val FALLBACK_TITLE = "تشغيل الأذان"
        const val FALLBACK_TEXT = "إشعار قائم أثناء تشغيل الأذان"
        const val FALLBACK_STOP = "إيقاف"
    }

    private var mediaPlayer: MediaPlayer? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var audioManager: AudioManager? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopAdhan()
            return START_NOT_STICKY
        }

        startForegroundWithType(
            intent?.getStringExtra(EXTRA_NOTIFICATION_TITLE),
            intent?.getStringExtra(EXTRA_NOTIFICATION_TEXT),
            intent?.getStringExtra(EXTRA_STOP_ACTION_LABEL)
        )
        playAdhan(intent?.getStringExtra(EXTRA_FILE_PATH))
        return START_NOT_STICKY
    }

    private fun startForegroundWithType(
        title: String?,
        text: String?,
        stopLabel: String?
    ) {
        val notification = buildNotification(title, text, stopLabel)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(
        title: String?,
        text: String?,
        stopLabel: String?
    ): Notification {
        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val resolvedTitle = title ?: FALLBACK_TITLE
        val channel = NotificationChannel(
            CHANNEL_ID,
            resolvedTitle,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = text ?: FALLBACK_TEXT
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)

        val stopIntent = PendingIntent.getService(
            this,
            0,
            Intent(this, AdhanPlaybackService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stopAction = Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_media_pause),
            stopLabel ?: FALLBACK_STOP,
            stopIntent
        ).build()

        val openAppIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE
        )

        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(resolvedTitle)
            .setContentText(text ?: FALLBACK_TEXT)
            .setOngoing(true)
            .setContentIntent(openAppIntent)
            .addAction(stopAction)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    private fun playAdhan(filePath: String?) {
        try {
            if (!requestAudioFocus()) {
                stopSelf()
                return
            }

            val player = if (!filePath.isNullOrEmpty() && File(filePath).exists()) {
                MediaPlayer().apply {
                    setDataSource(filePath)
                    prepare()
                }
            } else {
                val resourceId =
                    resources.getIdentifier(DEFAULT_RAW_NAME, "raw", packageName)
                if (resourceId == 0) {
                    stopSelf()
                    return
                }
                MediaPlayer.create(this, resourceId)
            }

            player.setOnCompletionListener { stopAdhan() }
            player.setOnErrorListener { _, _, _ ->
                stopAdhan()
                true
            }
            mediaPlayer = player
            player.start()
        } catch (e: Exception) {
            e.printStackTrace()
            stopAdhan()
        }
    }

    private fun requestAudioFocus(): Boolean {
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(attributes)
            .build()
        audioFocusRequest = request
        return audioManager?.requestAudioFocus(request) ==
            AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun stopAdhan() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
        }
        mediaPlayer = null

        audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
        audioFocusRequest = null

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopAdhan()
        super.onDestroy()
    }
}
