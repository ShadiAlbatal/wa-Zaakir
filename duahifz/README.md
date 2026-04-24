# DuaHifz

**Privacy-First Dua Memorization App with Real-Time Speech Recognition**

DuaHifz is a mobile application (Android first, iOS later) designed to help users memorize and practice Duas (Islamic supplications) through active recitation with real-time word-by-word matching. It's a local, private version inspired by Tarteel AI, but specifically optimized for short prayers rather than long Quranic surahs.

## Features

### Core MVP Features

#### 🔹 Sequential Real-Time Matching
- The app listens to your recitation and matches it word-by-word against the expected text
- **No skipping allowed**: If you skip words (e.g., read word 4 directly after word 1), the marker stops at the missing word (word 2) and waits for correct recitation
- Forces correct learning order

#### 🔹 Visual Feedback
- Beautiful Arabic typography with clear fonts (Amiri, Noto Sans Arabic)
- Dynamic word coloring:
  - 🟢 **Green**: Correctly recited
  - 🟡 **Yellow/Highlighted**: Current word being recited
  - ⚫ **Black/White**: Upcoming words
- **Hide/Show Text Mode**: Hide the text and recite from memory - the app will highlight which word you just recited and color it based on accuracy

#### 🔹 100% Local & Private (Privacy-First)
- All audio processing, speech recognition (ASR), and matching happens **entirely on-device**
- No audio is sent to the cloud - guaranteed full privacy
- Built on lightweight models (Whisper-tiny quantized, Silero VAD) via sherpa-onnx for high performance even on mobile devices

#### 🔹 Intelligent Sound Detection
- Uses Silero VAD (Voice Activity Detection) to automatically start recording when speech is detected and stop during silence
- Saves battery and makes interaction seamless without manual "start/stop" buttons during recitation

## Technical Architecture

### Frontend
- **Flutter (Dart)**: Unified and beautiful cross-platform UI

### Backend (On-device)
- **Native Kotlin (Android)**: Connected to C++ via JNI
- **sherpa-onnx**: Inference engine for maximum speed and minimal latency

### Models
- Fine-tuned Whisper models for Arabic religious texts
- ONNX format for efficient mobile hardware execution
- Silero VAD for voice activity detection

## Project Structure

```
duahifz/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── dua.dart              # Dua data model
│   ├── screens/
│   │   ├── home_screen.dart      # Dua list screen
│   │   └── recitation_screen.dart # Recitation practice screen
│   ├── services/
│   │   └── dua_provider.dart     # State management
│   └── widgets/
│       ├── arabic_text_display.dart  # Word-by-word display
│       ├── recitation_controls.dart  # Control buttons
│       └── progress_indicator.dart   # Progress bar
├── android/
│   └── app/
│       └── src/main/
│           ├── kotlin/com/duahifz/app/
│           │   ├── MainActivity.kt
│           │   └── SpeechRecognitionService.kt
│           └── cpp/
│               ├── CMakeLists.txt
│               └── speech_recognition.cpp
├── assets/
│   ├── fonts/
│   │   ├── Amiri-Regular.ttf
│   │   └── NotoSansArabic-Regular.ttf
│   ├── models/
│   │   ├── silero_vad.onnx
│   │   ├── tiny-ar-quran-encoder.int8.onnx
│   │   ├── tiny-ar-quran-decoder.int8.onnx
│   │   └── tokens.txt
│   └── duas/
│       └── sample_duas.json
└── pubspec.yaml
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio with NDK installed (for native compilation)
- Dart SDK (comes with Flutter)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd duahifz
```

2. Copy your model files to `assets/models/`:
```
- silero_vad.onnx
- tiny-ar-quran-encoder.int8.onnx
- tiny-ar-quran-decoder.int8.onnx
- tokens.txt
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Usage

1. **Select a Dua**: Choose from the list of available Duas on the home screen
2. **Start Reciting**: Press the microphone button to begin
3. **Follow the Highlight**: The current word will be highlighted in yellow
4. **Get Feedback**: Words turn green when correctly recited, red if incorrect
5. **Hide Text Mode**: Press "Hide" to test your memory - the app still tracks your progress
6. **Track Progress**: See your completion percentage at the top

## Roadmap

- [ ] Full sherpa-onnx integration with Whisper models
- [ ] Voice Activity Detection (VAD) auto-start/stop
- [ ] More Duas collection
- [ ] Spaced repetition algorithm for memorization
- [ ] Progress tracking and statistics
- [ ] iOS support
- [ ] Custom Dua import feature
- [ ] Multiple recitation modes (memorization, review, test)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for suggestions.

## Support

For support, please open an issue in the repository or contact the maintainers.

---

**Built with ❤️ for the Muslim Ummah**
