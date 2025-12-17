import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> init() async => await _stt.initialize();

  void listen({required Function(String) onResult}) {
    _stt.listen(onResult: (result) => onResult(result.recognizedWords));
  }

  void stop() => _stt.stop();

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}