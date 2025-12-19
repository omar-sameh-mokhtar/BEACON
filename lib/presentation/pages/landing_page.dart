import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/voice_viewmodel.dart';
import 'dart:async';
import '../../viewmodels/p2p_viewmodel.dart';

//final FlutterP2pHost hostInterface = FlutterP2pHost();
//final FlutterP2pClient clientInterface = FlutterP2pClient();



class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  //const LandingPage({super.key});

  Future<void> _prepareAndNavigate(BuildContext context, bool isHost) async {
    //_updateLog("Checking permissions and services...");
    final p2pVM = Provider.of<P2PViewModel>(context, listen: false);
    final hostInterface = p2pVM.service.hostInterface;
    // Check Permissions
    if (!await hostInterface.checkP2pPermissions()) {
      //_updateLog("Requesting P2P permissions...");
      await hostInterface.askP2pPermissions();
    }
    if (!await hostInterface.checkBluetoothPermissions()) {
      //_updateLog("Requesting Bluetooth permissions...");
      await hostInterface.askBluetoothPermissions();
    }

    // Check Services
    if (!await hostInterface.checkLocationEnabled()) {
      //_updateLog("Enabling Location...");
      await hostInterface.enableLocationServices();
    }
    if (!await hostInterface.checkWifiEnabled()) {
      //_updateLog("Enabling Wi-Fi...");
      await hostInterface.enableWifiServices();
    }

    //_updateLog("Navigating to Dashboard as ${isHost ? 'HOST' : 'CLIENT'}");
    if (!context.mounted) return;
    
    p2pVM.startGlobalEngine(isHost);
    
    context.goNamed('dashboard', pathParameters: {'isHost': '$isHost'});
  }

  
  @override
  Widget build(BuildContext context) {
    final voiceVM = Provider.of<VoiceViewModel>(context);

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
                        _prepareAndNavigate(context, true);
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
                        _prepareAndNavigate(context, false);
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
                    FloatingActionButton(
                      key: const Key('voice_button'),
                      backgroundColor: Colors.red,
                      elevation: 4,
                      onPressed: () => voiceVM.toggleListening(context),
                      child: Icon(voiceVM.isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
                    ),
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
