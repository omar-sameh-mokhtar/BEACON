class Device {
  final String? id;
  final String deviceId;
  final String name;
  final String lastSeen;          
  final String firstDiscovered;   
  final String connectionStatus;
  final bool isConnected;

  Device({
    this.id,
    required this.deviceId,
    required this.name,
    required this.lastSeen,
    required this.firstDiscovered,
    required this.connectionStatus,
    required this.isConnected,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'name': name,
      'last_seen': lastSeen,
      'first_discovered': firstDiscovered,
      'connection_status': connectionStatus,
      'is_connected': isConnected ? 1 : 0,
    };
  }

  factory Device.fromMap(Map<String, Object?> map) {
    return Device(
      id: map['id'] as String?,
      deviceId: map['device_id'] as String,
      name: map['name'] as String,
      lastSeen: map['last_seen'] as String,
      firstDiscovered: map['first_discovered'] as String,
      connectionStatus: map['connection_status'] as String,
      isConnected: (map['is_connected'] as int) == 1,
    );
  }

}
