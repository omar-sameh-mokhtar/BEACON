import 'package:beacon/viewmodels/p2p_viewmodel.dart';
import 'fake_host_interface.dart';

class FakeP2PViewModel extends P2PViewModel {
  bool? lastIsHost;

  @override
  void startGlobalEngine(bool isHost) {
    lastIsHost = isHost;
  }

  @override
  get service => _FakeService();
}

class _FakeService {
  final hostInterface = FakeHostInterface();
}
