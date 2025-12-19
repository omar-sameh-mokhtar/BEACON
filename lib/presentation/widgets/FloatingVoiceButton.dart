
import 'package:flutter/material.dart';
import '../../viewmodels/voice_viewmodel.dart';
import 'package:provider/provider.dart';

class Floatingvoicebutton extends StatelessWidget{

  final bool centre;
  const Floatingvoicebutton({super.key, required this.centre});

  @override
  Widget build(BuildContext context) {
    final voiceVM = Provider.of<VoiceViewModel>(context);
    if(!centre) {
      return FloatingActionButton(
        key: const Key('voice_button'),
        onPressed: () {voiceVM.toggleListening(context);},
        backgroundColor: Colors.red,
        child: const Icon(Icons.mic, color: Colors.white),

      );
    }
    else{
      return Center(
        child: FloatingActionButton(
          key: const Key('Centre_voice_button'),
          onPressed: () {voiceVM.toggleListening(context);},
          backgroundColor: Colors.red,
          child: const Icon(Icons.mic, color: Colors.white),
      )
      );
    }
  }
}