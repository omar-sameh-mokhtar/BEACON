import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../viewmodels/p2p_viewmodel.dart';
import '../../viewmodels/voice_viewmodel.dart';

class ChattingPage extends StatefulWidget {
  final P2pClientInfo target;
  final bool isHost;
  const ChattingPage({super.key, required this.target, required this.isHost});

  @override
  State<ChattingPage> createState() => ChattingPageState();
}

class ChattingPageState extends State<ChattingPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<P2PViewModel>().loadChatWithPeer(widget.target.id);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (picked == null) return;
    await context.read<P2PViewModel>().sendImageBase64(
      File(picked.path),
      widget.target.id,
    );
  }

  Future<void> _sendLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final String payload =
          "LOC|${position.latitude}|${position.longitude}";

      await context.read<P2PViewModel>().sendMessage(
        payload,
        widget.target.id,
        widget.isHost,
      );
    } catch (e) {
      debugPrint("[LOCATION_ERROR] $e");
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _isBase64Image(String content) {
    return content.startsWith('IMG_BASE64|');
  }

  bool _isLocation(String content) {
    return content.startsWith('LOC|');
  }

  @override
  Widget build(BuildContext context) {
    double width_ = MediaQuery.of(context).size.width;
    double height_ = MediaQuery.of(context).size.height;
    final vm = context.watch<P2PViewModel>();
    final voiceVm = context.watch<VoiceViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Text(
          "Chat with ${widget.target.username}",
          style: const TextStyle(color: Colors.white),
        ),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height_ * 0.01),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: height_ * 0.001),
                child: Container(
                  width: width_ * 0.95,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 48, 48, 48),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: vm.currentChatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = vm.currentChatMessages[index];
                      bool isMe = msg.senderDeviceId != widget.target.id;

                      // IMAGE MESSAGE
                      if (_isBase64Image(msg.content)) {
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.red : Colors.grey[700],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(
                                        msg.content
                                            .replaceFirst('IMG_BASE64|', ''),
                                      ),
                                      width: width_ * 0.55,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.broken_image,
                                          color: Colors.white54,
                                          size: 50,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.timestamp
                                        .split('T')
                                        .last
                                        .substring(0, 5),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // LOCATION MESSAGE
                      if (_isLocation(msg.content)) {
                        final parts = msg.content.split('|');
                        final double lat = double.tryParse(parts[1]) ?? 0;
                        final double lng = double.tryParse(parts[2]) ?? 0;

                        return GestureDetector(
                          onTap: () => _openInMaps(lat, lng),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.red : Colors.grey[700],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Lat: ${lat.toStringAsFixed(5)}\nLng: ${lng.toStringAsFixed(5)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Tap to open in Maps",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.timestamp
                                        .split('T')
                                        .last
                                        .substring(0, 5),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // TEXT MESSAGE
                      return GestureDetector(
                        onTap: () {
                          voiceVm.speakMessage(msg.content);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.red : Colors.grey[700],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.content,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.timestamp
                                      .split('T')
                                      .last
                                      .substring(0, 5),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: height_ * 0.01),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              width: width_ * 0.95,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 48, 48, 48),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _pickAndSendImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    onPressed: _sendLocation,
                  ),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Type or speak a message',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key("send_message_Button"),
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_ctrl.text.isNotEmpty) {
                        vm.sendMessage(
                            _ctrl.text, widget.target.id, widget.isHost);
                        _ctrl.clear();
                      }
                    },
                  ),
                  IconButton(
                    key: const Key("voice_dictation_button"),
                    icon: Icon(
                      voiceVm.isListening ? Icons.mic : Icons.mic_none,
                      color: voiceVm.isListening ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      if (voiceVm.isListening) {
                        voiceVm.stopDictation();
                      } else {
                        voiceVm.startDictation((text) {
                          setState(() {
                            _ctrl.text = text;
                          });
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: height_ * 0.03),
          ],
        ),
      ),
    );
  }
}