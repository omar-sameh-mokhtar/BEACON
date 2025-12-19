import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/voice_viewmodel.dart';
import '../../viewmodels/p2p_viewmodel.dart';
import 'package:go_router/go_router.dart';

import '../widgets/FloatingVoiceButton.dart';
//final FlutterP2pHost hostInterface = FlutterP2pHost();
//final FlutterP2pClient clientInterface = FlutterP2pClient();



class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  //const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceVM = Provider.of<VoiceViewModel>(context);
    final p2pVM = Provider.of<P2PViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 14, 15, 19),
              Color(0xFF1A0000),
              Color.fromARGB(255, 182, 42, 36),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    //might add logo laterrr
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'BEACON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Stay Connected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      key: const Key('start_button'),
                      onPressed: () {
                        p2pVM.initP2P(context, true);
                        context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Start Communication",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: const Key('join_button'),
                      onPressed: () {
                        p2pVM.initP2P(context, false);
                        context.goNamed('dashboard', pathParameters: {'isHost': '${p2pVM.isHost}'});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 14, 15, 19),
                        side: const BorderSide(color: Color.fromARGB(255, 14, 15, 19), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Join Communication",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Column(
                  children: [
                    Floatingvoicebutton(centre: true),
                    const SizedBox(height: 14),
                    Text(
                      voiceVM.isListening ? "Listening..." :"Press to start voice communication",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
