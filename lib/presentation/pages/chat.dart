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
                    height: height_ * 0.07,
                  width: width_ * 0.95,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 48, 48, 48),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                )),
                SizedBox(height: height_ * 0.04 ),
                Expanded(child:
                Padding(
                    padding: EdgeInsets.only(bottom: height_ * 0.1),
                    child: Container(
                      width: width_ * 0.95,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 48, 48, 48),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                )),
                ),
              Padding(
                padding:
                  EdgeInsets.symmetric(horizontal: width_ * 0.025, vertical: 10),
                    child: Column(
                        children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                            MessageButton('HELP',width_,height_),
                            MessageButton('LOCATION',width_,height_),
                            MessageButton('MEDICAL',width_,height_),
                        ],
                      )]))


            ]
    ),
    ));
  }


  Widget MessageButton(String text, double width_, double height_) {
    return ElevatedButton(
      onPressed: () {

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width_*height_*0.01),
        ),
      ),
      child: Text(text),
    );
  }


}
