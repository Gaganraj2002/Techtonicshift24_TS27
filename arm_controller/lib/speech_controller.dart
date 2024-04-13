// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxString _recognizedText = ''.obs;

  final RxBool isMicClicked = false.obs;

  final TextEditingController userCommandText = TextEditingController();

  // Getter for recognized text
  String get recognizedText => _recognizedText.value;

  // Method to start listening to speech
  void startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status😒: $status');
        },
        onError: (error) {
          print('Speech error🤨: $error');
        },
      );

      if (available) {
        _speech.listen(
          onResult: (result) {
            _recognizedText.value = result.recognizedWords;
          },
        );
      } else {
        print('Speech recognition is not available');
      }
    }
  }

  // Method to stop listening to speech
  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
