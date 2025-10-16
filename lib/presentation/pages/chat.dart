import 'package:flutter/material.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => ChattingPageState();
}

class ChattingPageState extends State<ChattingPage> {
  String selectedPerson = "Eslam";

  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage({String? text, bool isMe = true}) {
    String message = text ?? _textController.text;
    if (message.isEmpty) return;
    setState(() {
      _messages.add({'text': message, 'isMe': isMe});
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width_ = MediaQuery.of(context).size.width;
    double height_ = MediaQuery.of(context).size.height;

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
        title: Text("Chat with $selectedPerson"),
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
                  const Text("3 com", style: TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: msg['isMe'] ? Colors.red : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(color: Colors.white),
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
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type or speak a message',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(),
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
      onPressed: () => _sendMessage(text: text, isMe: false),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}
