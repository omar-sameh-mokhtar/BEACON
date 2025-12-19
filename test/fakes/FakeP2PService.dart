class FakeP2PService {
  bool startedAsHost = false;
  bool startedAsClient = false;

  void startGlobalEngine(bool isHost) {
    if (isHost) {
      startedAsHost = true;
    } else {
      startedAsClient = true;
    }
  }
}
