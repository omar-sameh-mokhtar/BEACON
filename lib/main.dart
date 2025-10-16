import 'package:beacon/presentation/pages/chat.dart';
import 'package:flutter/material.dart';
import 'presentation/pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BEACON',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const ChattingPage(),
    );
  }
}


