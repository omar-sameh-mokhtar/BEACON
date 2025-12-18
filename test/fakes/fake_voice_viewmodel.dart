import 'package:flutter/material.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';

class FakeVoiceViewModel extends ChangeNotifier
    implements VoiceViewModel {

  bool _isListening = false;
  bool toggleCalled = false;

  @override
  bool get isListening => _isListening;

  @override
  void toggleListening(BuildContext context) {
    toggleCalled = true;
    _isListening = !_isListening;
    notifyListeners();
  }
}
