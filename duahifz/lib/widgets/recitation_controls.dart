import 'package:flutter/material.dart';

/// Control buttons for recitation screen
class RecitationControlsWidget extends StatelessWidget {
  final bool isListening;
  final bool textVisible;
  final VoidCallback onToggleText;
  final VoidCallback onToggleListening;

  const RecitationControlsWidget({
    super.key,
    required this.isListening,
    required this.textVisible,
    required this.onToggleText,
    required this.onToggleListening,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hide/Show Text Button
          _buildControlButton(
            context,
            icon: textVisible ? Icons.visibility : Icons.visibility_off,
            label: textVisible ? 'Hide' : 'Show',
            onPressed: onToggleText,
            isActive: textVisible,
          ),
          
          // Microphone / Listening Button
          _buildControlButton(
            context,
            icon: isListening ? Icons.mic : Icons.mic_none,
            label: isListening ? 'Stop' : 'Listen',
            onPressed: onToggleListening,
            isActive: isListening,
            isPrimary: true,
          ),
          
          // Placeholder for future features (e.g., settings, help)
          _buildControlButton(
            context,
            icon: Icons.settings_outlined,
            label: 'Settings',
            onPressed: () {
              // TODO: Implement settings dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary
                ? (isActive
                    ? colorScheme.error
                    : colorScheme.primary)
                : (isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest),
            border: Border.all(
              color: isPrimary
                  ? (isActive
                      ? colorScheme.error
                      : colorScheme.primary)
                  : colorScheme.outline,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              size: 28,
              color: isPrimary
                  ? Colors.white
                  : (isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant),
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isPrimary
                ? (isActive
                    ? colorScheme.error
                    : colorScheme.primary)
                : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
