package com.alheekmah.aqimApp

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.alheekmah.aqimApp/raw_audio"
    private val ALARMS_CHANNEL = "com.alheekmah.aqimApp/adhan_alarms"
    private val ADHAN_ALARM_ACTION = "com.alheekmah.aqimApp.ADAN_ALARM"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRawAudioPath" -> {
                    val fileName = call.argument<String>("fileName")
                    if (fileName != null) {
                        val path = copyRawToCache(fileName)
                        if (path != null) {
                            result.success(path)
                        } else {
                            result.error("ERROR", "Could not copy raw file: $fileName", null)
                        }
                    } else {
                        result.error("ERROR", "File name is null", null)
                    }
                }
                "playRawAudio" -> {
                    val fileName = call.argument<String>("fileName")
                    if (fileName != null) {
                        val success = playRawAudio(fileName)
                        result.success(success)
                    } else {
                        result.error("ERROR", "File name is null", null)
                    }
                }
                "stopAudio" -> {
                    stopAudio()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAdhanAlarms" -> {
                    val alarms = call.argument<List<Map<String, Any?>>>("alarms") ?: emptyList()
                    scheduleAdhanAlarms(alarms)
                    result.success(true)
                }
                "cancelAdhanAlarms" -> {
                    val ids = call.argument<List<Int>>("ids") ?: emptyList()
                    cancelAdhanAlarms(ids)
                    result.success(true)
                }
                "hasExactAlarmPermission" -> {
                    result.success(hasExactAlarmPermission())
                }
                else -> result.notImplemented()
            }
        }
    }

    // ─── جدولة أذان المنبة الدقيقة (بالتوازي مع إشعارات FLN) ───

    private fun alarmManager(): AlarmManager =
        getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private fun hasExactAlarmPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            alarmManager().canScheduleExactAlarms()

    private fun alarmPendingIntent(id: Int, filePath: String?, title: String?, text: String?, stopLabel: String?): PendingIntent {
        val intent = Intent(this, AdhanAlarmReceiver::class.java)
            .setAction(ADHAN_ALARM_ACTION)
            .putExtra(AdhanPlaybackService.EXTRA_FILE_PATH, filePath)
            .putExtra(AdhanPlaybackService.EXTRA_NOTIFICATION_TITLE, title)
            .putExtra(AdhanPlaybackService.EXTRA_NOTIFICATION_TEXT, text)
            .putExtra(AdhanPlaybackService.EXTRA_STOP_ACTION_LABEL, stopLabel)
        return PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun scheduleAdhanAlarms(alarms: List<Map<String, Any?>>) {
        val manager = alarmManager()
        val canExact = hasExactAlarmPermission()
        for (alarm in alarms) {
            val id = (alarm["id"] as Number).toInt()
            val triggerAtMillis = (alarm["triggerAtMillis"] as Number).toLong()
            val filePath = alarm["filePath"] as String?
            val title = alarm["notificationTitle"] as String?
            val text = alarm["notificationText"] as String?
            val stopLabel = alarm["stopActionLabel"] as String?
            val pendingIntent = alarmPendingIntent(id, filePath, title, text, stopLabel)
            try {
                if (canExact) {
                    manager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                } else {
                    manager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                }
            } catch (e: SecurityException) {
                // سُحب إذن الإنذارات الدقيقة أثناء التشغيل؛ تراجع لجدولة مرنة.
                manager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
        }
    }

    private fun cancelAdhanAlarms(ids: List<Int>) {
        val manager = alarmManager()
        for (id in ids) {
            // filterEquals يتجاهل الإضافات؛ نفس المعرف يلغي الإنذار نفسه.
            manager.cancel(alarmPendingIntent(id, null, null, null, null))
        }
    }

    // ─── تشغيل موارد raw الخام (للمعاينة داخل التطبيق) ───

    private fun copyRawToCache(fileName: String): String? {
        return try {
            val resourceId = resources.getIdentifier(fileName, "raw", packageName)
            if (resourceId == 0) {
                return null
            }

            val cacheDir = File(cacheDir, "adhan_audio")
            if (!cacheDir.exists()) {
                cacheDir.mkdirs()
            }

            val outputFile = File(cacheDir, "$fileName.wav")
            
            // إذا كان الملف موجوداً بالفعل، أرجع مساره
            if (outputFile.exists()) {
                return outputFile.absolutePath
            }

            resources.openRawResource(resourceId).use { input ->
                FileOutputStream(outputFile).use { output ->
                    input.copyTo(output)
                }
            }

            outputFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun playRawAudio(fileName: String): Boolean {
        return try {
            stopAudio()
            
            val resourceId = resources.getIdentifier(fileName, "raw", packageName)
            if (resourceId == 0) {
                return false
            }

            mediaPlayer = MediaPlayer.create(this, resourceId)
            mediaPlayer?.start()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun stopAudio() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
    }
}
