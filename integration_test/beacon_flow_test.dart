import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/main.dart' as app;
import 'package:beacon/viewmodels/p2p_viewmodel.dart';

void main() {
  final binding =
  IntegrationTestWidgetsFlutterBinding.ensureInitialized()
  as IntegrationTestWidgetsFlutterBinding;

  binding.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Beacon join -> auto connect -> chat -> send message',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final joinBtn = find.byKey(const Key('start_button'));
      expect(joinBtn, findsOneWidget);

      await tester.tap(joinBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      late P2PViewModel vm;

      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(MaterialApp));
        vm = Provider.of<P2PViewModel>(ctx, listen: false);

        final timeout = DateTime.now().add(const Duration(seconds: 30));
        while (vm.peers.isEmpty) {
          if (DateTime.now().isAfter(timeout)) {
            throw Exception('Timeout: no host discovered');
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
      });

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      const msg = 'Hello from integration test';
      await tester.enterText(find.byType(TextField), msg);
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(msg), findsOneWidget);
    },
  );
}
