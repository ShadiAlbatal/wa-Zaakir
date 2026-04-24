import 'package:flutter/material.dart';

/// List tile for displaying Dua items in the home screen list
class DuaListTile extends StatelessWidget {
  final Map<String, String> dua;
  final VoidCallback? onTap;
  final double? progress;

  const DuaListTile({
    super.key,
    required this.dua,
    this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress ?? 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and progress
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic text preview
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dua['name'] ?? 'Unknown Dua',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dua['arabic'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            height: 1.8,
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Progress indicator
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        if (progressValue > 0) ...[
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircularProgressIndicator(
                                    value: progressValue / 100,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getProgressColor(progressValue),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${progressValue.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getProgressColor(progressValue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getProgressLabel(progressValue),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getProgressColor(progressValue),
                            ),
                          ),
                        ] else
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Reference and transliteration
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dua['reference'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green.shade700;
    if (progress >= 70) return Colors.blue.shade700;
    if (progress >= 50) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _getProgressLabel(double progress) {
    if (progress >= 90) return 'Mastered';
    if (progress >= 70) return 'Good';
    if (progress >= 50) return 'Learning';
    return 'Practice';
  }
}
