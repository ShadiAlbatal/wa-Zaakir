import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recitation_provider.dart';
import '../widgets/recording_button.dart';
import '../widgets/recognition_result_card.dart';
import '../widgets/dua_list_tile.dart';

/// Home screen with list of Duas for memorization practice
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample duas - replace with your actual dua collection
  final List<Map<String, String>> _duas = [
    {
      'id': '1',
      'name': 'Dua for Seeking Knowledge',
      'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
      'transliteration': 'Rabbi zidnee \'ilmaa',
      'translation': 'My Lord, increase me in knowledge',
      'reference': 'Surah Taha 20:114',
    },
    {
      'id': '2',
      'name': 'Dua for Parents',
      'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      'transliteration': 'Rabbir hamhumaa kamaa rabbayaanee sagheeraa',
      'translation': 'My Lord, have mercy upon them as they brought me up [when I was] small',
      'reference': 'Surah Al-Isra 17:24',
    },
    {
      'id': '3',
      'name': 'Dua for Forgiveness',
      'arabic': 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      'transliteration': 'Rabbanaa zalamnaaa anfusanaa wa il lam taghfir lanaa wa tarhamnaa lanakoonanna minal khaasireen',
      'translation': 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers',
      'reference': 'Surah Al-A\'raf 7:23',
    },
    {
      'id': '4',
      'name': 'Ayat al-Kursi',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Allaahu laa ilaaha illaa Huwal Hayyul Qayyoom',
      'translation': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence',
      'reference': 'Surah Al-Baqarah 2:255',
    },
    {
      'id': '5',
      'name': 'Last 2 Ayat of Al-Baqarah',
      'arabic': 'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ',
      'transliteration': 'Aamanar Rasoolu bimaaa unzila ilayhi mir Rabbihii wal mu\'minoon',
      'translation': 'The Messenger has believed in what was revealed to him from his Lord, and [so have] the believers',
      'reference': 'Surah Al-Baqarah 2:285-286',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dua Hifz'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to history screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with progress summary
          _buildHeader(),
          
          // Dua list
          Expanded(
            child: ListView.builder(
              itemCount: _duas.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final dua = _duas[index];
                return DuaListTile(
                  dua: dua,
                  onTap: () => _navigateToPracticeScreen(dua),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_stories,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Memorize Duas with AI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Practice recitation and get instant feedback',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToPracticeScreen(Map<String, String> dua) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(dua: dua),
      ),
    );
  }
}

/// Practice screen for individual Dua memorization
class PracticeScreen extends StatefulWidget {
  final Map<String, String> dua;

  const PracticeScreen({super.key, required this.dua});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dua['name'] ?? 'Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDuaInfo(),
          ),
        ],
      ),
      body: Consumer<RecitationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic text display
                _buildArabicText(),
                
                const SizedBox(height: 24),
                
                // Transliteration
                _buildTransliteration(),
                
                const SizedBox(height: 16),
                
                // Translation
                _buildTranslation(),
                
                const SizedBox(height: 32),
                
                // Recording button
                _buildRecordingButton(provider),
                
                const SizedBox(height: 24),
                
                // Recognition result
                if (provider.recognizedText.isNotEmpty || provider.error != null)
                  RecognitionResultCard(
                    recognizedText: provider.recognizedText,
                    confidence: provider.confidence,
                    error: provider.error,
                    onRetry: () => provider.clearRecognition(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildArabicText() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          widget.dua['arabic'] ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 32,
            height: 2.0,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildTransliteration() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.dua['transliteration'] ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildTranslation() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.dua['translation'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.dua['reference'] ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton(RecitationProvider provider) {
    return RecordingButton(
      isRecording: provider.isRecording,
      isProcessing: provider.isProcessing,
      onStartRecording: () {
        provider.startSession(widget.dua['name'] ?? 'Unknown');
        provider.setRecording(true);
        // Start audio recording and recognition
        // This would integrate with AudioRecordingService and QuranRecognitionService
      },
      onStopRecording: () async {
        provider.setRecording(false);
        provider.setProcessing(true);
        
        // Simulate processing delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Update with recognition result (placeholder)
        provider.updateRecognition(
          text: widget.dua['arabic'] ?? '',
          confidence: 0.85 + (DateTime.now().millisecond / 1000 * 0.15),
        );
        
        provider.setProcessing(false);
      },
      onCancelRecording: () {
        provider.setRecording(false);
        provider.clearRecognition();
      },
    );
  }

  void _showDuaInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.dua['name'] ?? 'Dua Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference: ${widget.dua['reference']}'),
            const SizedBox(height: 8),
            const Text('Tips for memorization:'),
            const SizedBox(height: 4),
            const Text('• Listen carefully to the pronunciation'),
            const Text('• Repeat slowly and clearly'),
            const Text('• Focus on one phrase at a time'),
            const Text('• Practice regularly'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
