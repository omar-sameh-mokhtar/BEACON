import 'package:beacon/presentation/pages/chat.dart';
import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/presentation/pages/resources.dart';
import 'package:flutter/material.dart';

import 'presentation/pages/profile.dart';
import 'presentation/pages/landing_page.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.red,
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      home: const LandingPage(),

    );
  }
}
