import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beacon/presentation/pages/profile.dart';
import 'package:beacon/viewmodels/ProfileViewModel.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'package:beacon/main.dart';

import '../fakes/FakeProfileViewModel.dart';
import '../fakes/spy_voice_viewmodel.dart';
import '../fakes/fake_p2p_viewmodel.dart';
import '../fakes/fake_my_app_state.dart';

void main() {
  testWidgets(
    'ProfilePage basic widgets exist',
        (WidgetTester tester) async {

      // Arrange
      final profileVM = FakeProfileViewModel();
      final voiceVM = SpyVoiceViewModel();
      final p2pVM = FakeP2PViewModel();
      final appState = FakeMyAppState();

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MyAppState>.value(
              value: appState,
            ),
            ChangeNotifierProvider<ProfileViewModel>.value(
              value: profileVM,
            ),
            ChangeNotifierProvider<VoiceViewModel>.value(
              value: voiceVM,
            ),
            ChangeNotifierProvider<P2PViewModel>.value(
              value: p2pVM,
            ),
          ],
          child: const MaterialApp(
            home: ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert

      // AppBar
      expect(find.byKey(const Key('app_bar')), findsOneWidget);

      // Bottom navigation bar
      expect(
        find.byKey(const Key('bottom_navigation_bar')),
        findsOneWidget,
      );

      // Floating voice button
      expect(
        find.byKey(const Key('voice_button')),
        findsOneWidget,
      );


    },
  );
}
