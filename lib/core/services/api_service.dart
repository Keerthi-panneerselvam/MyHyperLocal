import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceToTextHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  
  // Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
    
    // Initialize speech to text
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech to text error: $error'),
      onStatus: (status) => debugPrint('Speech to text status: $status'),
    );
    
    return _isInitialized;
  }
  
  // Check if speech recognition is available
  bool get isAvailable => _isInitialized;
  
  // Check if speech recognition is active
  bool get isListening => _speech.isListening;
  
  // Start listening for speech input
  Future<bool> startListening({
    required Function(String) onResult,
    required VoidCallback onDone,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }
    
    return await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          if (!_speech.isListening) {
            onDone();
          }
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: localeId,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }
  
  // Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
  
  // Cancel listening
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
  
  // Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return [];
      }
    }
    
    return _speech.locales();
  }
  
  // Dispose resources
  void dispose() {
    if (_speech.isListening) {
      _speech.cancel();
    }
  }
}