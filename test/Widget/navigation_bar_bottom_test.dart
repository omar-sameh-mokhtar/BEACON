import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/pages/dashboard.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';

import '../fakes/fake_p2p_viewmodel.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/dashboard/true',
      routes: [
        GoRoute(
          name: 'dashboard',
          path: '/dashboard/:isHost',
          builder: (context, state) {
            return Scaffold(
              body: Column(
                children: const [
                  Text('Dashboard Page'),
                  NavigationBarBottom(currentIndex: 0),
                ],
              ),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            return Scaffold(
              body: Column(
                children: const [
                  Text('Profile Page'),
                  NavigationBarBottom(currentIndex: 1),
                ],
              ),
            );
          },
        ),
        GoRoute(
          path: '/resources',
          builder: (context, state) {
            return Scaffold(
              body: Column(
                children: const [
                  Text('Resources Page'),
                  NavigationBarBottom(currentIndex: 2),
                ],
              ),
            );
          },
        ),
      ],
    );
  });

  testWidgets(
    'NavigationBarBottom navigation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<P2PViewModel>(
          create: (_) => FakeP2PViewModel(),
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dashboard
      expect(find.text('Dashboard Page'), findsOneWidget);

      // → Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);

      // → Resources
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();
      expect(find.text('Resources Page'), findsOneWidget);
    },
  );

}
