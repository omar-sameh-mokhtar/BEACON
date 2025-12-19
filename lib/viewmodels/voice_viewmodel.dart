import 'package:flutter/material.dart';
import '../model/service/voice_service.dart';
import 'p2p_viewmodel.dart';
import 'package:go_router/go_router.dart';
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
    
    if (command.contains("start")) {
      _service.speak("Starting communication");
      toggleListening(context);
      //p2pVM.prepareAndNavigate(context, true);
      
    } else if (command.contains("join")) {
      _service.speak("Joining existing network");
      toggleListening(context);
      //p2pVM.prepareAndNavigate(context, false);
    }
    else if(command.contains("resources")){
      _service.speak("Navigate to resources ");
      context.go('/resources');

    }
    else if (command.contains("profile")) {
      _service.speak("Navigate to profile ");
      context.go('/profile');
    }



  }
}