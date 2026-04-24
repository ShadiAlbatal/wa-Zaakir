import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:path_provider/path_provider.dart';
import 'screens/home_screen.dart';
import 'screens/recitation_screen.dart';
import 'services/dua_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize speech recognition models before running app
  await _initializeModels();
  
  runApp(const DuaHifzApp());
}

/// Initialize speech recognition models by copying them to accessible location
Future<void> _initializeModels() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/models';
    
    // Create models directory if it doesn't exist
    final dir = Directory(modelPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    debugPrint('Models directory ready at: $modelPath');
  } catch (e) {
    debugPrint('Error initializing models: $e');
  }
}

class DuaHifzApp extends StatelessWidget {
  const DuaHifzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DuaProvider(),
      child: MaterialApp(
        title: 'DuaHifz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'NotoSansArabic',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'NotoSansArabic',
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
