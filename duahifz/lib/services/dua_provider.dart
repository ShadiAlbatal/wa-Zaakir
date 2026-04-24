import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/dua.dart';
import 'speech_channel.dart';

/// Provider for managing Dua data and recitation state
class DuaProvider extends ChangeNotifier {
  List<Dua> _duas = [];
  Dua? _currentDua;
  
  // Recitation state
  int _currentWordIndex = -1;
  bool _isListening = false;
  bool _textVisible = true;
  final Map<int, bool> _wordAccuracy = {}; // wordIndex -> isCorrect
  
  // Speech recognition subscription
  StreamSubscription<String>? _recognitionSubscription;

  List<Dua> get duas => _duas;
  Dua? get currentDua => _currentDua;
  int get currentWordIndex => _currentWordIndex;
  bool get isListening => _isListening;
  bool get textVisible => _textVisible;
  Map<int, bool> get wordAccuracy => _wordAccuracy;

  /// Load Duas from assets JSON file
  Future<void> loadDuas() async {
    try {
      final jsonString = await rootBundle.loadString('assets/duas/sample_duas.json');
      final jsonData = jsonDecode(jsonString);
      
      if (jsonData is Map && jsonData['duas'] is List) {
        _duas = (jsonData['duas'] as List)
            .map((j) => Dua.fromJson(j))
            .toList();
        notifyListeners();
        debugPrint('Loaded ${_duas.length} Duas from JSON');
      } else {
        debugPrint('Invalid JSON structure');
      }
    } catch (e) {
      debugPrint('Error loading Duas: $e');
      // Fallback to empty list or sample data
      _duas = [];
      notifyListeners();
    }
  }

  /// Initialize speech recognition with model path
  Future<bool> initializeSpeechRecognition(String modelPath) async {
    final success = await SpeechChannel.initialize(modelPath);
    if (success) {
      debugPrint('Speech recognition initialized');
      _setupRecognitionListener();
    }
    return success;
  }

  /// Setup listener for recognition results
  void _setupRecognitionListener() {
    _recognitionSubscription?.cancel();
    _recognitionSubscription = SpeechChannel.recognitionResults.listen((result) {
      debugPrint('Recognition result: $result');
      // The native side handles word matching
      // Results are processed through callbacks
    });
  }

  /// Select a Dua for recitation and initialize speech recognition
  Future<void> selectDua(Dua dua) async {
    _currentDua = dua;
    _currentWordIndex = 0;
    _wordAccuracy.clear();
    _isListening = false;
    
    // Set the first expected word for recognition
    if (_currentDua != null && _currentDua!.words.isNotEmpty) {
      await SpeechChannel.setExpectedWord(_currentDua!.words[0], 0);
    }
    
    notifyListeners();
  }

  /// Update current word index during recitation
  void updateCurrentWord(int index, {bool? isCorrect}) {
    if (_currentDua == null) return;
    
    if (index >= 0 && index < _currentDua!.words.length) {
      _currentWordIndex = index;
      if (isCorrect != null) {
        _wordAccuracy[index] = isCorrect;
      }
      notifyListeners();
    }
  }

  /// Move to next word (called when current word is correctly recited)
  Future<void> advanceToNextWord() async {
    if (_currentDua == null) return;
    
    if (_currentWordIndex < _currentDua!.words.length - 1) {
      _currentWordIndex++;
      
      // Update expected word for recognition
      await SpeechChannel.setExpectedWord(
        _currentDua!.words[_currentWordIndex],
        _currentWordIndex,
      );
      
      notifyListeners();
    }
  }

  /// Toggle listening state and control native speech recognition
  Future<void> setListening(bool value) async {
    _isListening = value;
    
    if (value) {
      await SpeechChannel.startListening();
    } else {
      await SpeechChannel.stopListening();
    }
    
    notifyListeners();
  }

  /// Handle word recognition result from native side
  void onWordRecognized(String recognizedWord, int wordIndex, bool isCorrect) {
    if (_currentDua == null) return;
    
    debugPrint('Word recognized: "$recognizedWord" at index $wordIndex, correct: $isCorrect');
    
    _wordAccuracy[wordIndex] = isCorrect;
    
    if (isCorrect) {
      // Auto-advance to next word
      advanceToNextWord();
    }
    
    notifyListeners();
  }

  /// Toggle text visibility
  void toggleTextVisibility() {
    _textVisible = !_textVisible;
    notifyListeners();
  }

  /// Reset recitation progress
  Future<void> resetRecitation() async {
    _currentWordIndex = 0;
    _wordAccuracy.clear();
    _isListening = false;
    
    await SpeechChannel.stopListening();
    
    // Reset expected word
    if (_currentDua != null && _currentDua!.words.isNotEmpty) {
      await SpeechChannel.setExpectedWord(_currentDua!.words[0], 0);
    }
    
    notifyListeners();
  }

  /// Get accuracy status for a specific word
  bool? getWordAccuracy(int index) => _wordAccuracy[index];

  /// Calculate overall progress percentage
  double get progress {
    if (_currentDua == null || _currentDua!.words.isEmpty) return 0.0;
    final completedWords = _wordAccuracy.values.where((v) => v).length;
    return completedWords / _currentDua!.words.length;
  }

  @override
  void dispose() {
    _recognitionSubscription?.cancel();
    super.dispose();
  }
}
