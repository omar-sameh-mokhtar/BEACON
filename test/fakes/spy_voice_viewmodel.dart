import 'package:flutter/material.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'fake_p2p_viewmodel.dart';

class SpyVoiceViewModel extends ChangeNotifier implements VoiceViewModel {
  bool _isListening = false;

  bool toggleCalled = false;
  bool speakCalled = false;
  bool startDictationCalled = false;
  bool stopDictationCalled = false;

  final P2PViewModel _p2pVM = FakeP2PViewModel();

  @override
  bool get isListening => _isListening;

  @override
  P2PViewModel get p2pVM => _p2pVM;

  @override
  void toggleListening(
      BuildContext context,
      {Function(String)? onActionTriggered}
      ) {
    toggleCalled = true;
    _isListening = !_isListening;
    notifyListeners();

    if (onActionTriggered != null) {
      onActionTriggered("test");
    }
  }

  @override
  void startDictation(Function(String) onTextReceived) {
    startDictationCalled = true;
    _isListening = true;
    notifyListeners();

    onTextReceived("test message");
  }

  @override
  void stopDictation() {
    stopDictationCalled = true;
    _isListening = false;
    notifyListeners();
  }

  @override
  Future<void> speakMessage(String text) async {
    speakCalled = true;
  }
}
