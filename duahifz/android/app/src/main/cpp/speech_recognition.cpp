#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>

// sherpa-onnx includes (when integrated)
// #include "sherpa-onnx/c-api/c-api.h"

#define LOG_TAG "DuaHifzNative"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

/**
 * Initialize the speech recognizer with the model path
 * Returns a handle (pointer) to the recognizer instance
 */
JNIEXPORT jlong JNICALL
Java_com_duahifz_app_SpeechRecognitionService_initRecognizer(
    JNIEnv* env,
    jobject thiz,
    jstring modelPath) {
    
    const char* path = env->GetStringUTFChars(modelPath, nullptr);
    LOGD("Initializing recognizer with model path: %s", path);
    
    // TODO: Initialize sherpa-onnx recognizer here
    // Example:
    // SherpaOnnxOnlineRecognizerConfig config;
    // config.feat_config.sampling_rate = 16000;
    // config.model_config.transducer.encoder = std::string(path) + "/encoder.onnx";
    // config.model_config.transducer.decoder = std::string(path) + "/decoder.onnx";
    // auto recognizer = SherpaOnnxCreateOnlineRecognizer(&config);
    
    env->ReleaseStringUTFChars(modelPath, path);
    
    // Return dummy handle for now - replace with actual recognizer pointer
    return 0L;
}

/**
 * Process audio data through the recognizer
 * Returns true if speech was detected and recognized
 */
JNIEXPORT jboolean JNICALL
Java_com_duahifz_app_SpeechRecognitionService_processAudio(
    JNIEnv* env,
    jobject thiz,
    jlong handle,
    jshortArray audioData) {
    
    if (handle == 0L) {
        return JNI_FALSE;
    }
    
    jsize length = env->GetArrayLength(audioData);
    jshort* samples = env->GetShortArrayElements(audioData, nullptr);
    
    // Convert to float samples normalized to [-1, 1]
    std::vector<float> floatSamples(length);
    for (int i = 0; i < length; i++) {
        floatSamples[i] = samples[i] / 32768.0f;
    }
    
    env->ReleaseShortArrayElements(audioData, samples, JNI_ABORT);
    
    // TODO: Process audio through sherpa-onnx
    // SherpaOnnxOnlineStream* stream = SherpaOnnxCreateOnlineStream(recognizer);
    // SherpaOnnxOnlineStreamAcceptWaveform(stream, 16000, floatSamples.data(), length);
    // bool isReady = SherpaOnnxIsOnlineStreamReady(recognizer, stream);
    
    return JNI_FALSE; // Placeholder
}

/**
 * Get the current recognition result
 */
JNIEXPORT jstring JNICALL
Java_com_duahifz_app_SpeechRecognitionService_getResult(
    JNIEnv* env,
    jobject thiz,
    jlong handle) {
    
    if (handle == 0L) {
        return env->NewStringUTF("");
    }
    
    // TODO: Get result from sherpa-onnx
    // const char* result = SherpaOnnxGetOnlineStreamResult(recognizer, stream);
    
    return env->NewStringUTF(""); // Placeholder
}

/**
 * Destroy the recognizer and free resources
 */
JNIEXPORT void JNICALL
Java_com_duahifz_app_SpeechRecognitionService_destroyRecognizer(
    JNIEnv* env,
    jobject thiz,
    jlong handle) {
    
    if (handle == 0L) {
        return;
    }
    
    // TODO: Destroy sherpa-onnx recognizer
    // SherpaOnnxDestroyOnlineRecognizer(reinterpret_cast<SherpaOnnxOnlineRecognizer*>(handle));
    
    LOGD("Recognizer destroyed");
}

} // extern "C"
