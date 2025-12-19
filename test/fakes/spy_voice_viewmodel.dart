import 'package:flutter/material.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'fake_p2p_viewmodel.dart';

class SpyVoiceViewModel extends ChangeNotifier
    implements VoiceViewModel {

  bool _isListening = false;
  bool toggleCalled = false;

  final P2PViewModel _p2pVM = FakeP2PViewModel();

  @override
  bool get isListening => _isListening;

  @override
  P2PViewModel get p2pVM => _p2pVM;

  @override
  void toggleListening(BuildContext context) {
    toggleCalled = true;
    _isListening = !_isListening;
    notifyListeners();
  }
}
