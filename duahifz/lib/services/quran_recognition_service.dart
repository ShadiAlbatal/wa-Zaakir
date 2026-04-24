import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';

/// Service for Quran/Dua speech recognition using ONNX models
/// Uses the Silero VAD for voice activity detection and 
/// custom Quran encoder/decoder models for Arabic speech recognition
class QuranRecognitionService {
  static final QuranRecognitionService _instance = QuranRecognitionService._internal();
  factory QuranRecognitionService() => _instance;
  QuranRecognitionService._internal();

  OrtSession? _encoderSession;
  OrtSession? _decoderSession;
  OrtSession? _vadSession;
  List<String>? _tokens;
  bool _isInitialized = false;

  /// Initialize the ONNX models
  Future<void> initialize({
    required String encoderModelPath,
    required String decoderModelPath,
    required String vadModelPath,
    required String tokensPath,
  }) async {
    if (_isInitialized) return;

    try {
      // Load tokens
      final tokensData = await _loadTokens(tokensPath);
      _tokens = tokensData;

      // Initialize ONNX runtime sessions
      final env = OrtEnv.instance;
      
      _encoderSession = await OrtSession.createFromFile(encoderModelPath);
      _decoderSession = await OrtSession.createFromFile(decoderModelPath);
      _vadSession = await OrtSession.createFromFile(vadModelPath);

      _isInitialized = true;
      debugPrint('Quran Recognition Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Quran Recognition Service: $e');
      rethrow;
    }
  }

  /// Load tokens from file
  Future<List<String>> _loadTokens(String path) async {
    // This would read from assets in Flutter
    // For now, return a placeholder - implement based on your tokens.txt format
    final tokens = <String>[];
    // Read tokens.txt and parse
    // Each line typically contains: token_id token_text
    return tokens;
  }

  /// Process audio buffer and return recognized text
  Future<QuranRecognitionResult> recognizeSpeech(Float32List audioBuffer) async {
    if (!_isInitialized) {
      throw Exception('QuranRecognitionService not initialized');
    }

    try {
      // Step 1: Voice Activity Detection using Silero VAD
      final vadResult = await _detectVoiceActivity(audioBuffer);
      
      if (!vadResult.hasSpeech) {
        return QuranRecognitionResult(
          recognizedText: '',
          confidence: 0.0,
          hasSpeech: false,
        );
      }

      // Step 2: Extract features using encoder
      final encoderOutput = await _encodeAudio(audioBuffer);

      // Step 3: Decode to text using decoder
      final decodedText = await _decodeFeatures(encoderOutput);

      return QuranRecognitionResult(
        recognizedText: decodedText.text,
        confidence: decodedText.confidence,
        hasSpeech: true,
        startTime: vadResult.startTime,
        endTime: vadResult.endTime,
      );
    } catch (e) {
      debugPrint('Error in speech recognition: $e');
      return QuranRecognitionResult(
        recognizedText: '',
        confidence: 0.0,
        hasSpeech: false,
        error: e.toString(),
      );
    }
  }

  /// Detect voice activity in audio buffer
  Future<VADResult> _detectVoiceActivity(Float32List audioBuffer) async {
    if (_vadSession == null) {
      return VADResult(hasSpeech: false);
    }

    // Prepare input tensor for Silero VAD
    // Silero VAD expects specific input format
    final inputTensor = OrtTensor.fromFloat32Array(
      name: 'input',
      data: audioBuffer,
      shape: [1, audioBuffer.length], // Adjust based on model requirements
    );

    final outputs = await _vadSession!.run([inputTensor]);
    
    // Parse VAD output to determine if speech is present
    final speechProb = outputs.first.dataAsFloat32List()[0];
    final hasSpeech = speechProb > 0.5; // Threshold for speech detection

    return VADResult(
      hasSpeech: hasSpeech,
      confidence: speechProb,
    );
  }

  /// Encode audio to feature representation
  Future<Float32List> _encodeAudio(Float32List audioBuffer) async {
    if (_encoderSession == null) {
      throw Exception('Encoder session not initialized');
    }

    final inputTensor = OrtTensor.fromFloat32Array(
      name: 'input',
      data: audioBuffer,
      shape: [1, audioBuffer.length],
    );

    final outputs = await _encoderSession!.run([inputTensor]);
    return outputs.first.dataAsFloat32List();
  }

  /// Decode features to text
  Future<DecodedText> _decodeFeatures(Float32List features) async {
    if (_decoderSession == null || _tokens == null) {
      throw Exception('Decoder session or tokens not initialized');
    }

    final inputTensor = OrtTensor.fromFloat32Array(
      name: 'encoder_output',
      data: features,
      shape: [1, features.length],
    );

    final outputs = await _decoderSession!.run([inputTensor]);
    final tokenIds = outputs.first.dataAsInt32List();

    // Convert token IDs to text
    final textBuffer = StringBuffer();
    double totalConfidence = 0.0;
    
    for (final tokenId in tokenIds) {
      if (tokenId >= 0 && tokenId < _tokens!.length) {
        final token = _tokens![tokenId];
        if (token != '<pad>' && token != '<unk>' && token.isNotEmpty) {
          textBuffer.write(token);
          totalConfidence += 1.0;
        }
      }
    }

    final confidence = tokenIds.isNotEmpty ? totalConfidence / tokenIds.length : 0.0;

    return DecodedText(
      text: textBuffer.toString(),
      confidence: confidence,
    );
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    _encoderSession?.close();
    _decoderSession?.close();
    _vadSession?.close();
    _isInitialized = false;
  }
}

/// Result of Quran speech recognition
class QuranRecognitionResult {
  final String recognizedText;
  final double confidence;
  final bool hasSpeech;
  final Duration? startTime;
  final Duration? endTime;
  final String? error;

  QuranRecognitionResult({
    required this.recognizedText,
    required this.confidence,
    required this.hasSpeech,
    this.startTime,
    this.endTime,
    this.error,
  });
}

/// Voice Activity Detection result
class VADResult {
  final bool hasSpeech;
  final double? confidence;
  final Duration? startTime;
  final Duration? endTime;

  VADResult({
    required this.hasSpeech,
    this.confidence,
    this.startTime,
    this.endTime,
  });
}

/// Decoded text from model
class DecodedText {
  final String text;
  final double confidence;

  DecodedText({
    required this.text,
    required this.confidence,
  });
}
