import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'package:beacon/viewmodels/voice_viewmodel.dart';

import '../fakes/spy_voice_viewmodel.dart';

void main() {
  testWidgets(
    'Pressing floating voice button calls toggleListening',
        (WidgetTester tester) async {
      // Arrange
      final spyVoiceVM = SpyVoiceViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<VoiceViewModel>.value(
          value: spyVoiceVM,
          child: const MaterialApp(
            home: Scaffold(
              body: Floatingvoicebutton(centre: true),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Assert
      expect(spyVoiceVM.toggleCalled, true);
    },
  );
}
