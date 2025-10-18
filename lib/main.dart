import 'package:flutter/material.dart';

// Import your pages
import 'presentation/pages/dashboard.dart';
import 'presentation/pages/chat.dart';
import 'presentation/pages/profile.dart'; // 👈 make sure this file exists

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

      // 👇 Change this line to test the Profile Page
      home: const ProfilePage(),

      // You can later switch back to:
      // home: const ChattingPage(),
      // or home: const NetworkDashboardPage(),
    );
  }
}
