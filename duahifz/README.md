# Dua Hifz - AI-Powered Dua Memorization App

A Flutter application for memorizing Islamic Duas with AI-powered speech recognition, inspired by Tarteel.ai.

## Features

- 🎤 **Voice Recording**: Record your recitation of Duas
- 🤖 **AI Recognition**: Uses ONNX models (Silero VAD + custom Quran encoder/decoder) for speech recognition
- 📊 **Progress Tracking**: Track your memorization progress with confidence scores
- 📱 **Beautiful UI**: Modern Material Design 3 interface with Arabic font support
- 🔄 **Real-time Feedback**: Get instant feedback on your recitation accuracy

## Project Structure

```
duahifz/
├── assets/
│   ├── fonts/
│   │   ├── Amiri-Regular.ttf
│   │   └── NotoSansArabic-Regular.ttf
│   └── models/
│       ├── silero_vad.onnx
│       ├── tiny-ar-quran-decoder.int8.onnx
│       ├── tiny-ar-quran-encoder.int8.onnx
│       └── tokens.txt
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   └── home_screen.dart
│   ├── services/
│   │   ├── quran_recognition_service.dart
│   │   └── audio_recording_service.dart
│   ├── providers/
│   │   └── recitation_provider.dart
│   └── widgets/
│       ├── recording_button.dart
│       ├── recognition_result_card.dart
│       └── dua_list_tile.dart
└── pubspec.yaml
```

## Setup Instructions

### 1. Copy Your Model Files

Copy your model files from:
```
C:\USERS\SALEXT\PRV\APPSR\DIKR\PRJ\DUAHIFZ_MVP\DUAHIFZ\ASSETS
```

To the project's assets folder:
```
duahifz/assets/fonts/
duahifz/assets/models/
```

### 2. Install Dependencies

```bash
cd duahifz
flutter pub get
```

### 3. Platform-Specific Setup

#### Android

Add microphone permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS

Add microphone usage description to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your recitation for AI analysis</string>
```

### 4. Run the App

```bash
flutter run
```

## AI Models

This app uses the following ONNX models for speech recognition:

1. **Silero VAD** (`silero_vad.onnx`): Voice Activity Detection to identify when speech is present
2. **Quran Encoder** (`tiny-ar-quran-encoder.int8.onnx`): Encodes audio into feature representations
3. **Quran Decoder** (`tiny-ar-quran-decoder.int8.onnx`): Decodes features into Arabic text
4. **Tokens** (`tokens.txt`): Vocabulary mapping for token-to-text conversion

## How It Works

1. **Recording**: User presses the microphone button to start recording their recitation
2. **Voice Detection**: Silero VAD detects when speech begins and ends
3. **Feature Extraction**: The encoder processes the audio into features
4. **Text Recognition**: The decoder converts features to Arabic text
5. **Feedback**: The app compares recognized text with the expected Dua and provides confidence score

## Customization

### Adding More Duas

Edit the `_duas` list in `lib/screens/home_screen.dart`:

```dart
final List<Map<String, String>> _duas = [
  {
    'id': '1',
    'name': 'Dua Name',
    'arabic': 'Arabic text',
    'transliteration': 'Transliteration',
    'translation': 'Translation',
    'reference': 'Reference',
  },
  // Add more duas...
];
```

### Adjusting Recognition Thresholds

Modify the confidence threshold in `lib/services/quran_recognition_service.dart`:

```dart
final hasSpeech = speechProb > 0.5; // Adjust this threshold
```

## Troubleshooting

### Models Not Loading

Ensure all model files are correctly placed in `assets/models/` and listed in `pubspec.yaml`.

### Permission Issues

Make sure to grant microphone permissions when prompted by the app.

### Audio Quality

For best results:
- Record in a quiet environment
- Speak clearly and at moderate pace
- Hold the device at a consistent distance

## License

MIT License - See LICENSE file for details

## Credits

Inspired by [Tarteel.ai](https://tarteel.ai) - The AI-powered Quran memorization app.
