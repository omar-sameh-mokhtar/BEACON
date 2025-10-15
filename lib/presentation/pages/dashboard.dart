import 'package:flutter/material.dart';

class NetworkDashboardPage extends StatelessWidget {
  const NetworkDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Dashboard"),
      ),
      body: Center(
        child: Text("Dashboard Page"),
      ),
    );
  }
}
