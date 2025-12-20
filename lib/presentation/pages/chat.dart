import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'dart:async';
import '../../model/service/p2p_service.dart';
import '../../model/data/Message.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/p2p_viewmodel.dart';


class ChattingPage extends StatefulWidget {
  final P2pClientInfo target;
  final bool isHost;
  const ChattingPage({super.key, required this.target, required this.isHost});
  

  @override
  State<ChattingPage> createState() => ChattingPageState();
}

class ChattingPageState extends State<ChattingPage> {
  
 // final List<String> _history = [];
  final TextEditingController _ctrl = TextEditingController();
  //StreamSubscription? _msgSub;
/*
  @override
  void initState() {
    super.initState();
    final stream = widget.isHost ? widget.hostInterface.streamReceivedTexts() : widget.clientInterface.streamReceivedTexts();
    _msgSub = stream.listen((msg) {
      x="yes";
      print("[MSG RECEIVED] $msg");
      setState(() => _history.insert(0, "Peer: $msg"));

    });
  }
*//*
  void _send() async {
    if (_ctrl.text.isEmpty) return;
    bool ok = false;
    if (widget.isHost) {
      ok = await widget.hostInterface.sendTextToClient(_ctrl.text, widget.target.id);
    } else {
      await widget.clientInterface.broadcastText(_ctrl.text);
      ok = true;
    }
    if (ok) {
      setState(() {
        _history.insert(0, "Me: ${_ctrl.text}");
        _ctrl.clear();
      });
    }
  }
*//*
  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
*/
  @override
    void initState() {
      super.initState();
      // Initial load of messages for this specific peer
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<P2PViewModel>().refreshMessages(widget.target.id);
      });
  }
  @override
  Widget build(BuildContext context) {
    double width_ = MediaQuery.of(context).size.width;
    double height_ = MediaQuery.of(context).size.height;
    final vm = context.watch<P2PViewModel>();

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
        title: Text("Chat with ${widget.target.username}",
            style: const TextStyle(color: Colors.white)),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: height_ * 0.07,
              width: width_ * 0.95,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 48, 48, 48),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar, color: Colors.white),
                  const SizedBox(width: 10),
                   Text(widget.target.id, style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
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
                    return Container(
                      
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.red : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.timestamp.split('T').last.substring(0, 5), // Shows HH:mm
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
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
                const Icon(Icons.mic, color: Colors.white),
              ],
            ),
          ),
          SizedBox(height: height_ * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width_ * 0.025),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MessageButton('HELP'),
                MessageButton('LOCATION'),
                MessageButton('MEDICAL'),
              ],
            ),
          ),
          SizedBox(height: height_ * 0.03),
        ],
      ),
    );
  }

  Widget MessageButton(String text) {
    return ElevatedButton(

      onPressed: () => null,//_sendPredefinedMessage(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}
