import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/quran_recognition_service.dart';
import 'services/audio_recording_service.dart';
import 'providers/recitation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DuaHifzApp());
}

class DuaHifzApp extends StatelessWidget {
  const DuaHifzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecitationProvider()),
      ],
      child: MaterialApp(
        title: 'Dua Hifz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.light,
          ),
          fontFamily: 'NotoSansArabic',
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            brightness: Brightness.dark,
          ),
          fontFamily: 'NotoSansArabic',
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
