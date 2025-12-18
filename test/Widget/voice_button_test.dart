import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:beacon/presentation/pages/landing_page.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';

import '../fakes/fake_p2p_viewmodel.dart';
import '../fakes/fake_voice_viewmodel.dart';

void main() {
  testWidgets(
    'Pressing voice button toggles listening state',
        (WidgetTester tester) async {

      // ================== FIX SCREEN SIZE ==================
      tester.binding.window.physicalSizeTestValue =
      const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      // ================== FAKES ==================
      final fakeVoiceVM = FakeVoiceViewModel();
      final fakeP2PVM = FakeP2PViewModel();

      // ================== ROUTER ==================
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LandingPage(),
          ),
        ],
      );

      // ================== APP ==================
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<P2PViewModel>.value(
              value: fakeP2PVM,
            ),
            ChangeNotifierProvider<VoiceViewModel>.value(
              value: fakeVoiceVM,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ================== BEFORE PRESS ==================
      expect(fakeVoiceVM.isListening, false);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);

      // ================== ACTION ==================
      await tester.tap(find.byKey(const Key('voice_button')));
      await tester.pumpAndSettle();

      // ================== AFTER PRESS ==================
      expect(fakeVoiceVM.toggleCalled, true);
      expect(fakeVoiceVM.isListening, true);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    },
  );
}
