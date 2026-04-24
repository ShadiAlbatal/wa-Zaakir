import 'package:flutter/foundation.dart';

/// Provider for managing recitation state and recognition results
class RecitationProvider extends ChangeNotifier {
  bool _isRecording = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  String? _error;
  List<RecitationSession> _sessions = [];
  RecitationSession? _currentSession;

  /// Start a new recitation session
  void startSession(String duaName) {
    _currentSession = RecitationSession(
      duaName: duaName,
      startTime: DateTime.now(),
    );
    _isRecording = false;
    _isProcessing = false;
    _recognizedText = '';
    _confidence = 0.0;
    _error = null;
    notifyListeners();
  }

  /// End current session
  void endSession() {
    if (_currentSession != null) {
      _currentSession!.endTime = DateTime.now();
      _sessions.add(_currentSession!);
      _currentSession = null;
    }
    _isRecording = false;
    _isProcessing = false;
    notifyListeners();
  }

  /// Set recording state
  void setRecording(bool recording) {
    _isRecording = recording;
    if (recording && _currentSession == null) {
      _currentSession = RecitationSession(
        duaName: 'Unknown',
        startTime: DateTime.now(),
      );
    }
    notifyListeners();
  }

  /// Set processing state
  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  /// Update recognized text
  void updateRecognition({
    required String text,
    required double confidence,
    String? error,
  }) {
    _recognizedText = text;
    _confidence = confidence;
    _error = error;
    
    if (_currentSession != null && text.isNotEmpty) {
      _currentSession!.addAttempt(
        text: text,
        confidence: confidence,
        timestamp: DateTime.now(),
      );
    }
    
    notifyListeners();
  }

  /// Clear current recognition result
  void clearRecognition() {
    _recognizedText = '';
    _confidence = 0.0;
    _error = null;
    notifyListeners();
  }

  /// Get all sessions
  List<RecitationSession> get sessions => List.unmodifiable(_sessions);

  /// Get current session
  RecitationSession? get currentSession => _currentSession;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Check if currently processing
  bool get isProcessing => _isProcessing;

  /// Get recognized text
  String get recognizedText => _recognizedText;

  /// Get confidence score
  double get confidence => _confidence;

  /// Get error message
  String? get error => _error;

  /// Calculate overall progress for a dua
  double calculateProgress(String duaName) {
    final duaSessions = _sessions.where((s) => s.duaName == duaName).toList();
    if (duaSessions.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int count = 0;
    
    for (final session in duaSessions) {
      for (final attempt in session.attempts) {
        totalConfidence += attempt.confidence;
        count++;
      }
    }
    
    return count > 0 ? (totalConfidence / count) * 100 : 0.0;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Represents a recitation practice session
class RecitationSession {
  final String duaName;
  final DateTime startTime;
  DateTime? endTime;
  final List<RecitationAttempt> attempts;

  RecitationSession({
    required this.duaName,
    required this.startTime,
    this.endTime,
    List<RecitationAttempt>? attempts,
  }) : attempts = attempts ?? [];

  /// Add a recitation attempt
  void addAttempt({
    required String text,
    required double confidence,
    required DateTime timestamp,
  }) {
    attempts.add(RecitationAttempt(
      text: text,
      confidence: confidence,
      timestamp: timestamp,
    ));
  }

  /// Get best attempt (highest confidence)
  RecitationAttempt? get bestAttempt {
    if (attempts.isEmpty) return null;
    return attempts.reduce((a, b) => 
      a.confidence > b.confidence ? a : b
    );
  }

  /// Get average confidence
  double get averageConfidence {
    if (attempts.isEmpty) return 0.0;
    final total = attempts.fold<double>(0.0, (sum, attempt) => sum + attempt.confidence);
    return total / attempts.length;
  }

  /// Get session duration
  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }
}

/// Represents a single recitation attempt
class RecitationAttempt {
  final String text;
  final double confidence;
  final DateTime timestamp;

  RecitationAttempt({
    required this.text,
    required this.confidence,
    required this.timestamp,
  });
}
