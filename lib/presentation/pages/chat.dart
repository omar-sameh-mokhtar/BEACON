import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<P2PViewModel>().loadChatWithPeer(widget.target.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
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

                      if (msg.content.contains("FALL_DETECTED")) {
                        return const SizedBox.shrink();
                      }

                      bool isMe = msg.senderDeviceId != widget.target.id;

                      return GestureDetector(
                        onTap: () => voiceVm.speakMessage(msg.content),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                  msg.timestamp.split('T').last.substring(0, 5),
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
                        vm.sendMessage(_ctrl.text, widget.target.id, widget.isHost);
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