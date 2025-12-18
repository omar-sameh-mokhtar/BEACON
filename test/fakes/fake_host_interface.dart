class FakeHostInterface {
  Future<bool> checkP2pPermissions() async => true;
  Future<bool> checkBluetoothPermissions() async => true;
  Future<bool> checkLocationEnabled() async => true;
  Future<bool> checkWifiEnabled() async => true;

  Future<void> askP2pPermissions() async {}
  Future<void> askBluetoothPermissions() async {}
  Future<void> enableLocationServices() async {}
  Future<void> enableWifiServices() async {}
}
