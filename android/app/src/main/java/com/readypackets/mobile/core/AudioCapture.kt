package com.readypackets.mobile.core

import android.content.Context
import android.media.MediaRecorder
import java.io.File

/** Platform-native AAC/M4A recorder. Files remain in app-private cache until upload. */
class AudioCapture {
    private var recorder: MediaRecorder? = null
    private var output: File? = null

    fun start(context: Context): Result<File> = runCatching {
        check(recorder == null) { "A recording is already in progress." }
        val file = File.createTempFile("readypackets-", ".m4a", context.cacheDir)
        val next = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            setOutputFile(file.absolutePath)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setAudioSamplingRate(44_100)
            setAudioChannels(1)
            setAudioEncodingBitRate(96_000)
            prepare()
            start()
        }
        recorder = next; output = file; file
    }

    fun stop(): File? {
        val file = output
        runCatching { recorder?.stop() }
        recorder?.release(); recorder = null; output = null
        return file?.takeIf { it.exists() && it.length() > 0 }
    }

    fun release() { runCatching { recorder?.release() }; recorder = null; output?.delete(); output = null }
}
