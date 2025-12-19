import 'package:flutter/material.dart';
import 'package:beacon/viewmodels/p2p_viewmodel.dart';

class FakeP2PViewModel extends P2PViewModel {
  bool? lastIsHost;

  @override
  Future<void> initP2P(BuildContext context, bool host) async {
    isHost = host;
    lastIsHost = host;
    notifyListeners();
  }

  @override
  Future<void> startGlobalEngine(bool isHost) async {
    lastIsHost = isHost;
  }
}
