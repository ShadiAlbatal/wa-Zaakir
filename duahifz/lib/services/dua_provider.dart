import 'package:flutter/foundation.dart';
import '../models/dua.dart';

/// Provider for managing Dua data and recitation state
class DuaProvider extends ChangeNotifier {
  List<Dua> _duas = [];
  Dua? _currentDua;
  
  // Recitation state
  int _currentWordIndex = -1;
  bool _isListening = false;
  bool _textVisible = true;
  final Map<int, bool> _wordAccuracy = {}; // wordIndex -> isCorrect

  List<Dua> get duas => _duas;
  Dua? get currentDua => _currentDua;
  int get currentWordIndex => _currentWordIndex;
  bool get isListening => _isListening;
  bool get textVisible => _textVisible;
  Map<int, bool> get wordAccuracy => _wordAccuracy;

  /// Load Duas from assets (in production, load from JSON files)
  Future<void> loadDuas() async {
    // Sample Duas - in production, load from assets/duas/*.json
    _duas = [
      Dua.fromText(
        id: 'dua_1',
        title: 'Bismillah',
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        translation: 'In the name of Allah, the Most Gracious, the Most Merciful',
      ),
      Dua.fromText(
        id: 'dua_2',
        title: 'Alhamdulillah',
        arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        translation: 'All praise is due to Allah, Lord of the worlds',
      ),
      Dua.fromText(
        id: 'dua_3',
        title: 'Ayat al-Kursi (First part)',
        arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence',
      ),
    ];
    notifyListeners();
  }

  /// Select a Dua for recitation
  void selectDua(Dua dua) {
    _currentDua = dua;
    _currentWordIndex = 0;
    _wordAccuracy.clear();
    _isListening = false;
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
  void advanceToNextWord() {
    if (_currentDua == null) return;
    
    if (_currentWordIndex < _currentDua!.words.length - 1) {
      _currentWordIndex++;
      notifyListeners();
    }
  }

  /// Toggle listening state
  void setListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  /// Toggle text visibility
  void toggleTextVisibility() {
    _textVisible = !_textVisible;
    notifyListeners();
  }

  /// Reset recitation progress
  void resetRecitation() {
    _currentWordIndex = 0;
    _wordAccuracy.clear();
    _isListening = false;
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
}
