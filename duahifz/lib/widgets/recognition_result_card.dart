import 'package:flutter/material.dart';

/// Card displaying speech recognition results
class RecognitionResultCard extends StatelessWidget {
  final String recognizedText;
  final double confidence;
  final String? error;
  final VoidCallback? onRetry;

  const RecognitionResultCard({
    super.key,
    required this.recognizedText,
    required this.confidence,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorCard(context);
    }

    return _buildResultCard(context);
  }

  Widget _buildResultCard(BuildContext context) {
    final confidenceLevel = _getConfidenceLevel(confidence);
    final color = _getConfidenceColor(confidenceLevel);

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with confidence indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recognition Result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildConfidenceIndicator(confidence, confidenceLevel),
              ],
            ),
            
            const Divider(height: 24),
            
            // Recognized Arabic text
            if (recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    height: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Confidence score details
            _buildConfidenceDetails(context, confidenceLevel),
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recognition Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence, ConfidenceLevel level) {
    IconData icon;
    String label;

    switch (level) {
      case ConfidenceLevel.excellent:
        icon = Icons.emoji_events;
        label = 'Excellent';
        break;
      case ConfidenceLevel.good:
        icon = Icons.thumb_up;
        label = 'Good';
        break;
      case ConfidenceLevel.fair:
        icon = Icons.check_circle;
        label = 'Fair';
        break;
      case ConfidenceLevel.poor:
        icon = Icons.warning;
        label = 'Needs Practice';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _getConfidenceColor(level), size: 32),
        const SizedBox(height: 4),
        Text(
          '${(confidence * 100).toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getConfidenceColor(level),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _getConfidenceColor(level),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceDetails(BuildContext context, ConfidenceLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getConfidenceColor(level),
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Accuracy Score',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ConfidenceLevel _getConfidenceLevel(double confidence) {
    if (confidence >= 0.9) return ConfidenceLevel.excellent;
    if (confidence >= 0.75) return ConfidenceLevel.good;
    if (confidence >= 0.6) return ConfidenceLevel.fair;
    return ConfidenceLevel.poor;
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.excellent:
        return Colors.green.shade700;
      case ConfidenceLevel.good:
        return Colors.blue.shade700;
      case ConfidenceLevel.fair:
        return Colors.orange.shade700;
      case ConfidenceLevel.poor:
        return Colors.red.shade700;
    }
  }
}

enum ConfidenceLevel { excellent, good, fair, poor }
