package com.alheekmah.aqimApp

import android.content.Context
import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.alheekmah.aqimApp/raw_audio"
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
    }

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
