import '../data/Device.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class DeviceMapper {
  static Device fromBle(BleDiscoveredDevice ble) {
    final now = DateTime.now().toIso8601String();

    return Device(
      deviceId: ble.deviceAddress,
      name: ble.deviceName?.isNotEmpty == true
          ? ble.deviceName!
          : "Unknown Device",
      lastSeen: now,
      firstDiscovered: now,
      connectionStatus: "idle",
      isConnected: false,
    );
  }
}
