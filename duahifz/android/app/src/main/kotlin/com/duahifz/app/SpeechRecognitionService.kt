package com.duahifz.app

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Native speech recognition service using sherpa-onnx for local, privacy-first ASR.
 * This class handles audio recording and interfaces with the native C++ sherpa-onnx engine.
 */
class SpeechRecognitionService(private val context: Context) {
    
    companion object {
        private const val TAG = "SpeechRecognition"
        private const val SAMPLE_RATE = 16000
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
    }

    // Native method declarations (JNI)
    external fun initRecognizer(modelPath: String): Long
    external fun processAudio(handle: Long, audioData: ShortArray): Boolean
    external fun getResult(handle: Long): String
    external fun destroyRecognizer(handle: Long)

    private var recognizerHandle: Long = 0
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    
    // Callbacks
    var onWordRecognized: ((String, Int, Boolean) -> Unit)? = null
    var onError: ((String) -> Unit)? = null
    var onListeningStateChanged: ((Boolean) -> Unit)? = null

    /**
     * Initialize the speech recognizer with model path
     */
    fun initialize(modelPath: String): Boolean {
        return try {
            recognizerHandle = initRecognizer(modelPath)
            recognizerHandle != 0L
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize recognizer", e)
            onError?.invoke("Failed to initialize speech recognition")
            false
        }
    }

    /**
     * Start listening for speech
     */
    fun startListening() {
        if (isRecording) return

        val minBufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT)
        if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
            onError?.invoke("Invalid audio buffer size")
            return
        }

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            CHANNEL_CONFIG,
            AUDIO_FORMAT,
            minBufferSize * 2
        )

        if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
            onError?.invoke("Failed to initialize audio recorder")
            audioRecord?.release()
            audioRecord = null
            return
        }

        isRecording = true
        onListeningStateChanged?.invoke(true)

        executor.execute {
            recordAndProcessAudio()
        }
    }

    /**
     * Stop listening
     */
    fun stopListening() {
        isRecording = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        onListeningStateChanged?.invoke(false)
    }

    /**
     * Release resources
     */
    fun release() {
        stopListening()
        if (recognizerHandle != 0L) {
            destroyRecognizer(recognizerHandle)
            recognizerHandle = 0
        }
        executor.shutdown()
    }

    /**
     * Record audio and process it through the recognizer
     */
    private fun recordAndProcessAudio() {
        val bufferSize = 4096
        val audioBuffer = ShortArray(bufferSize)

        audioRecord?.startRecording()

        while (isRecording) {
            val readSize = audioRecord?.read(audioBuffer, 0, bufferSize) ?: 0
            
            if (readSize > 0) {
                val recognized = processAudio(recognizerHandle, audioBuffer)
                
                if (recognized) {
                    val result = getResult(recognizerHandle)
                    processRecognitionResult(result)
                }
            }
        }
    }

    /**
     * Process recognition result and match against expected words
     */
    private fun processRecognitionResult(result: String) {
        Log.d(TAG, "Recognized: $result")
        // This would be integrated with the DuaProvider to match words
        // For now, just callback with the recognized text
    }

    // Load native library
    init {
        System.loadLibrary("duahifz_native")
    }
}
