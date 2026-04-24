import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'dart:typed_data';

/// Service for audio recording functionality
class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  StreamController<Float32List>? _audioStreamController;
  Timer? _recordingTimer;

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    return await _recorder.requestPermission();
  }

  /// Start recording with real-time audio streaming
  Future<void> startRecording({
    Function(Float32List audioData)? onAudioData,
    Duration chunkDuration = const Duration(milliseconds: 100),
  }) async {
    if (_isRecording) return;

    try {
      // Check and request permission
      if (!await hasPermission()) {
        if (!await requestPermission()) {
          throw Exception('Microphone permission denied');
        }
      }

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000, // Silero VAD works best at 16kHz
        numChannels: 1,
        bitRate: 128000,
      );

      // Start recording
      await _recorder.start(config);
      _isRecording = true;

      // Stream audio data in chunks
      _audioStreamController = StreamController<Float32List>.broadcast();

      // Periodically capture audio data
      _recordingTimer = Timer.periodic(chunkDuration, (timer) async {
        if (!_isRecording) {
          timer.cancel();
          return;
        }

        // Note: The record package doesn't directly support streaming PCM data
        // You may need to use a different approach or package for real-time streaming
        // This is a placeholder - implement based on your needs
      });

      debugPrint('Recording started');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      rethrow;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      _recordingTimer?.cancel();
      _audioStreamController?.close();
      
      final path = await _recorder.stop();
      _isRecording = false;
      
      debugPrint('Recording stopped: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      rethrow;
    }
  }

  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      _recordingTimer?.cancel();
      _audioStreamController?.close();
      await _recorder.stop();
      _isRecording = false;
      
      debugPrint('Recording cancelled');
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
      _isRecording = false;
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get audio stream
  Stream<Float32List>? get audioStream => _audioStreamController?.stream;

  /// Dispose resources
  void dispose() {
    if (_isRecording) {
      stopRecording();
    }
    _audioStreamController?.close();
    _recordingTimer?.cancel();
  }
}
