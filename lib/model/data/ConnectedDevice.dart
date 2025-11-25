class ConnectedDevice {
  final int id;
  final String deviceId;
  final String name;
  final String lastSeen;
  final String connectionStatus;
  final int signalStrength;
  final String firstDiscovered;

  ConnectedDevice({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.lastSeen,
    required this.connectionStatus,
    required this.signalStrength,
    required this.firstDiscovered,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'name': name,
      'last_seen': lastSeen,
      'connection_type': connectionStatus,
      'signal_strength': signalStrength,
      'first_discovered': firstDiscovered,
    };
  }

  @override
  String toString() {
    return 'ConnectedDevice{id: $id, deviceId: $deviceId, name: $name, '
        'lastSeen: $lastSeen, connectionType: $connectionStatus, '
        'signalStrength: $signalStrength, firstDiscovered: $firstDiscovered}';
  }
}
