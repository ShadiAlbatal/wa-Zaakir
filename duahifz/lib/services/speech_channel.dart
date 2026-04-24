import 'package:flutter/services.dart';
import 'dart:async';

/// MethodChannel bridge for speech recognition communication with native Android
class SpeechChannel {
  static const MethodChannel _channel = MethodChannel('com.duahifz.app/speech');

  static bool _initialized = false;
  static StreamController<String>? _resultController;

  /// Initialize the speech recognizer with the model path
  static Future<bool> initialize(String modelPath) async {
    try {
      final success = await _channel.invokeMethod<bool>(
        'initRecognizer',
        {'modelPath': modelPath},
      );
      if (success == true) {
        _initialized = true;
        _setupResultListener();
      }
      return success ?? false;
    } on PlatformException catch (e) {
      print('Failed to initialize recognizer: ${e.message}');
      return false;
    }
  }

  /// Check if the recognizer is initialized
  static bool get isInitialized => _initialized;

  /// Setup listener for continuous recognition results
  static void _setupResultListener() {
    _resultController = StreamController<String>.broadcast();
    
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onRecognitionResult') {
        final result = call.arguments as String;
        _resultController?.add(result);
        return true;
      }
      return false;
    });
  }

  /// Stream of recognition results
  static Stream<String> get recognitionResults {
    if (_resultController == null) {
      _setupResultListener();
    }
    return _resultController!.stream;
  }

  /// Start listening for speech
  static Future<bool> startListening() async {
    if (!_initialized) {
      print('Recognizer not initialized');
      return false;
    }
    
    try {
      final success = await _channel.invokeMethod<bool>('startListening');
      return success ?? false;
    } on PlatformException catch (e) {
      print('Failed to start listening: ${e.message}');
      return false;
    }
  }

  /// Stop listening
  static Future<bool> stopListening() async {
    try {
      final success = await _channel.invokeMethod<bool>('stopListening');
      return success ?? false;
    } on PlatformException catch (e) {
      print('Failed to stop listening: ${e.message}');
      return false;
    }
  }

  /// Get current recognition result (one-time query)
  static Future<String> getResult() async {
    try {
      final result = await _channel.invokeMethod<String>('getResult');
      return result ?? '';
    } on PlatformException catch (e) {
      print('Failed to get result: ${e.message}');
      return '';
    }
  }

  /// Set the expected word for matching
  static Future<void> setExpectedWord(String word, int index) async {
    try {
      await _channel.invokeMethod('setExpectedWord', {
        'word': word,
        'index': index,
      });
    } on PlatformException catch (e) {
      print('Failed to set expected word: ${e.message}');
    }
  }

  /// Release resources
  static Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
      _initialized = false;
      await _resultController?.close();
      _resultController = null;
    } on PlatformException catch (e) {
      print('Failed to release: ${e.message}');
    }
  }
}
