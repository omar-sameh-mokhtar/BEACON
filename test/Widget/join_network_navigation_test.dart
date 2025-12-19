import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:beacon/presentation/pages/landing_page.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';

import '../fakes/fake_p2p_viewmodel.dart';
import '../fakes/spy_voice_viewmodel.dart';
import '../fakes/fake_network_dashboard.dart';

void main() {
  testWidgets(
    'Join Communication navigates to Network Dashboard (Client)',
        (WidgetTester tester) async {
      // ---------- Screen size fix ----------
      tester.binding.window.physicalSizeTestValue =
      const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      // ---------- Fakes ----------
      final fakeP2PVM = FakeP2PViewModel();

      // ---------- Router ----------
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LandingPage(),
          ),
          GoRoute(
            name: 'dashboard',
            path: '/dashboard/:isHost',
            builder: (context, state) {
              final isHost =
                  state.pathParameters['isHost'] == 'true';
              return FakeNetworkDashboard(isHost: isHost);
            },
          ),
        ],
      );

      // ---------- App ----------
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<P2PViewModel>.value(
              value: fakeP2PVM,
            ),
            ChangeNotifierProvider<VoiceViewModel>(
              create: (_) => SpyVoiceViewModel(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('Centre_voice_button')), findsOneWidget);
      // ---------- Action ----------
      expect(find.byKey(const Key('join_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('join_button')));
      await tester.pumpAndSettle();

      // ---------- Assert ----------
      expect(find.byKey(const Key('dashboard_page')), findsOneWidget);
      expect(find.text('CLIENT DASHBOARD'), findsOneWidget);
      expect(fakeP2PVM.lastIsHost, false);
    },
  );
}
