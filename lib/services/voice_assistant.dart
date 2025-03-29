import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistant {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  
  // Initialize the voice assistant
  Future<void> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    
    if (available) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    }
  }
  
  // Start listening for voice commands
  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
        localeId: 'en_US',
      );
    }
  }
  
  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
  
  // Speak a response
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }
  
  // Check if the assistant is currently listening
  bool get isListening => _isListening;
  
  // Process the voice command
  String processVoiceCommand(String command) {
    command = command.toLowerCase();
    
    if (command.contains('weather') || command.contains('temperature')) {
      if (command.contains('tomorrow') || command.contains('forecast')) {
        return 'forecast';
      } else if (command.contains('week') || command.contains('7 day')) {
        return 'weekly';
      } else {
        return 'current';
      }
    } else if (command.contains('alert') || command.contains('warning')) {
      return 'alerts';
    } else if (command.contains('dark') || command.contains('light') || command.contains('theme')) {
      return 'theme';
    } else {
      return 'unknown';
    }
  }
}