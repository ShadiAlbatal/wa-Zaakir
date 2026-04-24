import 'package:flutter/material.dart';

/// Widget for displaying Arabic text with word-by-word highlighting
class ArabicTextDisplayWidget extends StatelessWidget {
  final List<String> words;
  final int currentIndex;
  final bool textVisible;
  final Map<int, bool> wordAccuracy;

  const ArabicTextDisplayWidget({
    super.key,
    required this.words,
    required this.currentIndex,
    required this.textVisible,
    required this.wordAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    if (!textVisible) {
      // Text is hidden - show placeholder with current word indicator
      return _buildHiddenTextMode(context);
    }

    // Text is visible - show full text with highlighting
    return _buildVisibleTextMode(context);
  }

  Widget _buildHiddenTextMode(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Text Hidden - Recite from Memory',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          if (currentIndex >= 0 && currentIndex < words.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getWordColor(currentIndex).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getWordColor(currentIndex),
                  width: 2,
                ),
              ),
              child: Text(
                'Current Word: ${currentIndex + 1} / ${words.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: _getWordColor(currentIndex),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVisibleTextMode(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < words.length; i++) ...[
              _buildWordSpan(context, i),
              if (i < words.length - 1)
                const SizedBox(width: 8), // Space between words
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordSpan(BuildContext context, int index) {
    final isCurrent = index == currentIndex;
    final isCompleted = index < currentIndex;
    final accuracy = wordAccuracy[index];

    Color textColor;
    FontWeight fontWeight;
    double fontSize;
    BoxDecoration? decoration;

    if (isCompleted) {
      // Word already recited
      if (accuracy == true) {
        textColor = Colors.green; // Correct
      } else if (accuracy == false) {
        textColor = Colors.red; // Incorrect
      } else {
        textColor = Colors.grey; // Completed but not evaluated
      }
      fontWeight = FontWeight.normal;
      fontSize = 28;
    } else if (isCurrent) {
      // Current word being recited
      textColor = _getWordColor(index);
      fontWeight = FontWeight.bold;
      fontSize = 32;
      decoration = BoxDecoration(
        color: textColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor,
          width: 2,
        ),
      );
    } else {
      // Upcoming words
      textColor = Theme.of(context).colorScheme.onSurface;
      fontWeight = FontWeight.normal;
      fontSize = 28;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: decoration,
      child: Text(
        words[index],
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          height: 2.0,
        ),
      ),
    );
  }

  Color _getWordColor(int index) {
    // Yellow/amber for current word to indicate active focus
    return Colors.amber.shade700;
  }
}
