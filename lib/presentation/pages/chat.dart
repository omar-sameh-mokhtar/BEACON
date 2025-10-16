import 'package:flutter/material.dart';

class ChattingPage extends StatefulWidget {
  const ChattingPage({super.key});

  @override
  State<ChattingPage> createState() => ChattingPageState();
}

class ChattingPageState extends State<ChattingPage> {
  String selectedPerson = "Eslam";

  @override
  Widget build(BuildContext context) {
    double width_ = MediaQuery.of(context).size.width;
    double height_ = MediaQuery.of(context).size.height;

    return (Scaffold(
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
                    Icon(Icons.radar, color: Colors.white),
                    SizedBox(width: 10),
                    Text("3 com" , style: TextStyle(color: Colors.white)),
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
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type or speak a message ',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.mic, color: Colors.white),
              ],
            ),
          ),
          SizedBox(height: height_ * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width_ * 0.025,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MessageButton('HELP'),
                    MessageButton('LOCATION'),
                    MessageButton('MEDICAL'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: height_ * 0.03),
        ],
      ),
    ));
  }


  Widget MessageButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }
}
