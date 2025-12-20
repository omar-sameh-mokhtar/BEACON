import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:beacon/main.dart' as app;
import 'package:flutter/material.dart';



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Landing → Dashboard flow', (tester) async {

    app.main();


    await tester.pumpAndSettle();


    expect(find.text('BEACON'), findsOneWidget);

    // اضغط Start Communication
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pumpAndSettle();


    expect(find.textContaining('Network Dashboard'), findsOneWidget);
  });
}
