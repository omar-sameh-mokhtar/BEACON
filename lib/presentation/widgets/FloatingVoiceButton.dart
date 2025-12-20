
import 'package:flutter/material.dart';
import '../../viewmodels/voice_viewmodel.dart';
import 'package:provider/provider.dart';

class Floatingvoicebutton extends StatelessWidget{

  final bool centre;
  final Function(String)? onVoiceAction;
  const Floatingvoicebutton({super.key, required this.centre, this.onVoiceAction});

  @override
  Widget build(BuildContext context) {
    final voiceVM = Provider.of<VoiceViewModel>(context);
    if(!centre) {
      return FloatingActionButton(
        key: const Key('voice_button'),
        onPressed: () {voiceVM.toggleListening(context, onActionTriggered: onVoiceAction);},
        backgroundColor: Colors.red,
        child: const Icon(Icons.mic, color: Colors.white),

      );
    }
    else{
      return Center(
        child: FloatingActionButton(
          key: const Key('Centre_voice_button'),
          onPressed: () {voiceVM.toggleListening(context, onActionTriggered: onVoiceAction);},
          backgroundColor: Colors.red,
          child: const Icon(Icons.mic, color: Colors.white),
      )
      );
    }
  }
}