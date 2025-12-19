import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beacon/presentation/pages/resources.dart';
import 'package:beacon/viewmodels/resources_viewmodel.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'package:beacon/main.dart';

import '../fakes/fake_resources_viewmodel.dart';
import '../fakes/spy_voice_viewmodel.dart';
import '../fakes/fake_p2p_viewmodel.dart';
import '../fakes/fake_my_app_state.dart';

void main() {
  testWidgets(
    'ResourcesPage basic widgets exist',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [

            ChangeNotifierProvider<MyAppState>(
              create: (_) => FakeMyAppState(),
            ),

            ChangeNotifierProvider<ResourcesViewModel>(
              create: (_) => FakeResourcesViewModel(),
            ),

            ChangeNotifierProvider<VoiceViewModel>(
              create: (_) => SpyVoiceViewModel(),
            ),

            ChangeNotifierProvider<P2PViewModel>(
              create: (_) => FakeP2PViewModel(),
            ),
          ],
          child: const MaterialApp(
            home: ResourcesPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Assert

      // AppBar
      expect(find.byKey(const Key('app_bar')), findsOneWidget);


      // Tabs
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Shelter'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);

      // Add Resource button
      expect(find.text('Add Resource'), findsOneWidget);

      // Voice button
      expect(find.byKey(const Key('voice_button')), findsOneWidget);

      // Bottom navigation bar
      expect(find.byKey(const Key('bottom_navigation_bar')), findsOneWidget);
    },
  );
}
