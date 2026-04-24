import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dua_provider.dart';
import '../widgets/arabic_text_display.dart';
import '../widgets/recitation_controls.dart';
import '../widgets/progress_indicator.dart';

/// Screen for reciting and memorizing a selected Dua
class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize speech recognition when screen loads
    _initializeSpeechRecognition();
  }

  Future<void> _initializeSpeechRecognition() async {
    final provider = context.read<DuaProvider>();
    
    // Use assets path for models - in production, copy to accessible location first
    const modelPath = '/data/user/0/com.duahifz.app/files/models';
    await provider.initializeSpeechRecognition(modelPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DuaProvider>(
          builder: (context, provider, _) => Text(provider.currentDua?.title ?? 'Recitation'),
        ),
        centerTitle: true,
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DuaProvider>().resetRecitation();
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Consumer<DuaProvider>(
        builder: (context, provider, child) {
          final currentDua = provider.currentDua;
          
          if (currentDua == null) {
            return const Center(
              child: Text('No Dua selected'),
            );
          }

          return Column(
            children: [
              // Progress indicator
              ProgressIndicatorWidget(progress: provider.progress),
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Arabic text display with word-by-word highlighting
                      Expanded(
                        child: ArabicTextDisplayWidget(
                          words: currentDua.words,
                          currentIndex: provider.currentWordIndex,
                          textVisible: provider.textVisible,
                          wordAccuracy: provider.wordAccuracy,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Translation (optional, can be hidden)
                      if (provider.textVisible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            currentDua.translation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Controls
                      RecitationControlsWidget(
                        isListening: provider.isListening,
                        textVisible: provider.textVisible,
                        onToggleText: () => provider.toggleTextVisibility(),
                        onToggleListening: () async {
                          // Toggle listening state through provider
                          await provider.setListening(!provider.isListening);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup speech recognition
    context.read<DuaProvider>().setListening(false);
    super.dispose();
  }
}
