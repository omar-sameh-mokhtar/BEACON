import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import '../fakes/spy_voice_viewmodel.dart';
import '../fakes/fake_build_context.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceViewModel Unit Tests', () {
    test('toggleListening turns listening ON', () {
      // ARRANGE
      final vm = SpyVoiceViewModel();
      final context = FakeBuildContext();

      expect(vm.isListening, false);

      // ACT
      vm.toggleListening(context);

      // ASSERT
      expect(vm.isListening, true);
      expect(vm.toggleCalled, true);
    });

    test('toggleListening turns listening OFF', () {
      // ARRANGE
      final vm = SpyVoiceViewModel();
      final context = FakeBuildContext();

      // ACT
      vm.toggleListening(context); // ON
      vm.toggleListening(context); // OFF

      // ASSERT
      expect(vm.isListening, false);
    });
  });
}
