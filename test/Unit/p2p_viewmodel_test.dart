import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_p2p_viewmodel.dart';

void main() {
  group('P2PViewModel Unit Tests', () {
    test('startGlobalEngine initializes Host mode', () {
      final vm = FakeP2PViewModel();

      vm.startGlobalEngine(true);

      expect(vm.lastIsHost, true);
    });

    test('startGlobalEngine initializes Client mode', () {
      final vm = FakeP2PViewModel();

      vm.startGlobalEngine(false);

      expect(vm.lastIsHost, false);
    });
  });
}
