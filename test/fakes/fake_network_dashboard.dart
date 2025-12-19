import 'package:flutter/material.dart';

class FakeNetworkDashboard extends StatelessWidget {
  final bool isHost;
  const FakeNetworkDashboard({super.key, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('dashboard_page'),
      body: Center(
        child: Text(
          isHost ? 'HOST DASHBOARD' : 'CLIENT DASHBOARD',
        ),
      ),
    );
  }
}
