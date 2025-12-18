import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_voice_viewmodel.dart';
import '../fakes/fake_build_context.dart';

void main() {
  group('VoiceViewModel Unit Tests', () {
    test('toggleListening turns listening ON', () {
      final vm = FakeVoiceViewModel();
      final context = FakeBuildContext();

      expect(vm.isListening, false);

      vm.toggleListening(context);

      expect(vm.isListening, true);
    });

    test('toggleListening turns listening OFF', () {
      final vm = FakeVoiceViewModel();
      final context = FakeBuildContext();

      vm.toggleListening(context);
      vm.toggleListening(context);

      expect(vm.isListening, false);
    });
  });
}
