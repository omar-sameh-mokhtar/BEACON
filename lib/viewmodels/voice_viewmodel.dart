import 'package:flutter/material.dart';
import '../model/service/voice_service.dart';
import 'p2p_viewmodel.dart';
import 'package:go_router/go_router.dart';
class VoiceViewModel extends ChangeNotifier {
  final VoiceService _service = VoiceService();
  final P2PViewModel p2pVM = P2PViewModel();
  bool _isListening = false;
  
  bool get isListening => _isListening;
 
  void toggleListening(BuildContext context, {Function(String)? onActionTriggered}) async {
    if (_isListening) {
      _service.stop();
      _isListening = false;
    } else {
      bool available = await _service.init();
      if (available) {
        _isListening = true;
        _service.listen(onResult: (text) {
          _handleVoiceCommands(text.toLowerCase(), context, onActionTriggered);
        });
      }
    }
    notifyListeners();
  }

  void _handleVoiceCommands(String command, BuildContext context, Function(String)? onActionTriggered) {
    
    List<String> validCommands = ["broadcast"];
    for (var cmd in validCommands) {
      if (command.contains(cmd)) {
        _service.speak("Executing $cmd");
        toggleListening(context); 
        
        if (onActionTriggered != null) onActionTriggered(cmd); 
        return;
      }
    }

    
    if (command.contains("start")) {
      _service.speak("Starting communication");
      toggleListening(context);
      p2pVM.initP2P(context, true);
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'});
      
    } else if (command.contains("join")) {
      _service.speak("Joining existing network");
      toggleListening(context);
      //p2pVM.prepareAndNavigate(context, false);
      p2pVM.initP2P(context, false);
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'});
    }
    if(command.contains("resources")){
      _service.speak("Navigate to resources ");
      toggleListening(context);
      context.go('/resources');


    }
    else if (command.contains("profile")) {
      _service.speak("Navigate to profile");
      toggleListening(context);
      context.go('/profile');
    }

    else if (command.contains("dashboard")) {
      _service.speak("Navigate to dashboard");
      toggleListening(context);
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'}); 
    }
/*
    else if (command.contains("broadcast")) {
      _service.speak("Send broadcast message");
      toggleListening(context);
      context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'}); 
    }*/



  }


  void startDictation(Function(String) onTextReceived) async {
    bool available = await _service.init();
    if (available) {
      _isListening = true;
      notifyListeners();
      
      _service.listen(onResult: (text) {
        onTextReceived(text);
      });
    }
  }

  void stopDictation() {
    _service.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speakMessage(String text) async {
    await _service.speak(text);
  }
}