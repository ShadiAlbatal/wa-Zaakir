package com.duahifz.app

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
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
        
        // MethodChannel for Flutter communication
        private const val CHANNEL_NAME = "com.duahifz.app/speech"
        
        @JvmStatic
        fun registerWith(engine: FlutterEngine, context: Context) {
            val service = SpeechRecognitionService(context)
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
                when (call.method) {
                    "initRecognizer" -> {
                        val modelPath = call.argument<String>("modelPath") ?: ""
                        val success = service.initialize(modelPath)
                        result.success(success)
                    }
                    "startListening" -> {
                        service.startListening()
                        result.success(true)
                    }
                    "stopListening" -> {
                        service.stopListening()
                        result.success(true)
                    }
                    "getResult" -> {
                        val currentResult = service.currentResult
                        result.success(currentResult)
                    }
                    "setExpectedWord" -> {
                        val word = call.argument<String>("word") ?: ""
                        val index = call.argument<Int>("index") ?: 0
                        service.setExpectedWord(word, index)
                        result.success(null)
                    }
                    "release" -> {
                        service.release()
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
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
    
    // Current state
    var currentResult: String = ""
        private set
    private var expectedWord: String = ""
    private var expectedWordIndex: Int = 0
    
    // Callbacks
    var onWordRecognized: ((String, Int, Boolean) -> Unit)? = null
    var onError: ((String) -> Unit)? = null
    var onListeningStateChanged: ((Boolean) -> Unit)? = null
    var onRecognitionResult: ((String) -> Unit)? = null

    /**
     * Initialize the speech recognizer with model path
     */
    fun initialize(modelPath: String): Boolean {
        return try {
            Log.d(TAG, "Initializing recognizer with model path: $modelPath")
            recognizerHandle = initRecognizer(modelPath)
            val success = recognizerHandle != 0L
            if (success) {
                Log.d(TAG, "Recognizer initialized successfully")
            } else {
                Log.e(TAG, "Failed to initialize recognizer - handle is null")
                // For now, return true even with dummy implementation
                // Remove this when sherpa-onnx is integrated
                return true
            }
            success
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize recognizer", e)
            onError?.invoke("Failed to initialize speech recognition: ${e.message}")
            false
        }
    }

    /**
     * Set the expected word for matching
     */
    fun setExpectedWord(word: String, index: Int) {
        expectedWord = word
        expectedWordIndex = index
        Log.d(TAG, "Set expected word: $word at index $index")
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
        Log.d(TAG, "Started listening")

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
        Log.d(TAG, "Stopped listening")
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
        Log.d(TAG, "Resources released")
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
        if (result.isEmpty()) return
        
        currentResult = result
        Log.d(TAG, "Recognized: $result")
        
        // Notify Flutter of the result
        onRecognitionResult?.invoke(result)
        
        // Match against expected word if set
        if (expectedWord.isNotEmpty()) {
            val isMatch = compareArabicWords(result, expectedWord)
            Log.d(TAG, "Expected: $expectedWord, Match: $isMatch")
            onWordRecognized?.invoke(result, expectedWordIndex, isMatch)
        }
    }

    /**
     * Compare Arabic words with basic normalization
     */
    private fun compareArabicWords(recognized: String, expected: String): Boolean {
        // Basic comparison - in production, add more sophisticated matching
        // Handle diacritics, different forms, etc.
        val normalizedRecognized = normalizeArabicText(recognized)
        val normalizedExpected = normalizeArabicText(expected)
        
        // Check if recognized contains the expected word or vice versa
        return normalizedRecognized.contains(normalizedExpected) || 
               normalizedExpected.contains(normalizedRecognized) ||
               normalizedRecognized == normalizedExpected
    }

    /**
     * Normalize Arabic text by removing diacritics and standardizing forms
     */
    private fun normalizeArabicText(text: String): String {
        return text
            .replace(Regex("[\\u064B-\\u065F]"), "") // Remove diacritics
            .replace("أ", "ا") // Standardize Alif forms
            .replace("إ", "ا")
            .replace("آ", "ا")
            .replace("ى", "ي") // Standardize Yeh forms
            .replace("ة", "ه") // Standardize Taa Marbuta
            .trim()
    }

    // TODO: Load native library when sherpa-onnx is integrated
    // init {
    //     System.loadLibrary("duahifz_native")
    // }
    
    // Temporary stub implementation until native library is ready
    private var isInitialized = false
    private var lastRecognizedText = ""
    
    private fun initRecognizerNative(modelPath: String): Boolean {
        // TODO: Implement with sherpa-onnx
        isInitialized = true
        return true
    }
    
    private fun startListeningNative(): Boolean {
        if (!isInitialized) return false
        // TODO: Implement actual recording and recognition
        // For now, simulate recognition after delay
        simulateRecognition()
        return true
    }
    
    private fun stopListeningNative() {
        // TODO: Implement
    }
    
    private fun getResultNative(): String {
        return lastRecognizedText
    }
    
    private fun setExpectedWordNative(word: String): Boolean {
        // TODO: Implement matching logic
        return true
    }
    
    private fun releaseNative() {
        isInitialized = false
    }
    
    private fun simulateRecognition() {
        // Simulate recognition callback after 2 seconds
        Thread {
            Thread.sleep(2000)
            // Send dummy recognized text for testing
            val expectedWords = listOf("بِسْمِ", "اللَّهِ", "الرَّحْمَٰنِ", "الرَّحِيمِ")
            val randomWord = expectedWords.random()
            lastRecognizedText = randomWord
            
            // Notify Flutter via handler
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                try {
                    eventSink?.success(mapOf(
                        "type" to "recognition",
                        "text" to randomWord,
                        "confidence" to 0.85
                    ))
                } catch (e: Exception) {
                    // Event sink might be null
                }
            }
        }.start()
    }
}
