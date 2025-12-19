import 'package:flutter/material.dart';
import '../model/service/voice_service.dart';
import 'package:go_router/go_router.dart';
import 'p2p_viewmodel.dart';

class VoiceViewModel extends ChangeNotifier {
  final VoiceService _service = VoiceService();
  final P2PViewModel p2pVM = P2PViewModel();
  bool _isListening = false;
  
  bool get isListening => _isListening;
 
  void toggleListening(BuildContext context) async {
    if (_isListening) {
      _service.stop();
      _isListening = false;
    } else {
      bool available = await _service.init();
      if (available) {
        _isListening = true;
        _service.listen(onResult: (text) {
          _handleVoiceCommands(text.toLowerCase(), context);
        });
      }
    }
    notifyListeners();
  }

  void _handleVoiceCommands(String command, BuildContext context) {
    
    if (command.contains("start") || command.contains("communication")) {
      _service.speak("Starting communication");
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'}); 
    } else if (command.contains("join")) {
      _service.speak("Joining existing network");
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'}); 
    }
  }
}