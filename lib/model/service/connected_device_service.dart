import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/ConnectedDevice.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class ConnectedDeviceDao {
  final db = DatabaseHelper.instance;

  Future<int> insertConnectedDevice(ConnectedDevice device) async {
    final database = await db.database;
    return await database.insert(
      'connected_devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ConnectedDevice>> getAll() async {
    final database = await db.database;
    final List<Map<String, Object?>> result = await database.query('connected_devices');

    return [
      for (final {
        'id': id as int,
        'device_id': deviceId as String,
        'name': name as String,
        'last_seen': lastSeen as String,
        'connection_status': connectionType as String,
        'signal_strength': signalStrength as int,
        'first_discovered': firstDiscovered as String
      } in result)
        ConnectedDevice(
          id: id,
          deviceId: deviceId,
          name: name,
          lastSeen: lastSeen,
          connectionStatus: connectionType,
          signalStrength: signalStrength,
          firstDiscovered: firstDiscovered,
        )
    ];
  }

  Future<void> updateConnectedDevice(ConnectedDevice device) async {
    final database = await db.database;
    await database.update(
      'connected_devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<void> deleteConnectedDevice(int id) async {
    final database = await db.database;
    await database.delete(
      'connected_devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
