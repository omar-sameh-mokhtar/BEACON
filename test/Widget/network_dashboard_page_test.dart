import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'package:beacon/main.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';

import '../fakes/fake_my_app_state.dart';
import '../fakes/fake_p2p_viewmodel.dart';
import '../fakes/spy_voice_viewmodel.dart';

void main() {
  testWidgets(
    'NetworkDashboardPage basic widgets exist',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [

            ChangeNotifierProvider<MyAppState>(
              create: (_) => FakeMyAppState(),
            ),

            ChangeNotifierProvider<P2PViewModel>(
              create: (_) => FakeP2PViewModel(),
            ),


            ChangeNotifierProvider<VoiceViewModel>(
              create: (_) => SpyVoiceViewModel(),
            ),
          ],
          child: const MaterialApp(
            home: NetworkDashboardPage(isHost: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AppBar
      expect(find.byKey(const Key('app_bar')), findsWidgets);

      // Status
      expect(find.textContaining('Connected:'), findsOneWidget);
      expect(find.textContaining('Network Status:'), findsOneWidget);

      // Broadcast button
      expect(find.byKey(const Key('Broadcast_button')), findsOneWidget);
      expect(find.text('Send Broadcast Message'), findsOneWidget);

      // Floating voice button
      expect(find.byKey(const Key('voice_button')), findsOneWidget);

      // Bottom navigation
      expect(find.byKey(const Key('bottom_navigation_bar')), findsOneWidget);
    },
  );
}
