import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/ResourceRequest.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class ResourceRequestDao {
  final db = DatabaseHelper.instance;

  Future<int> insertResourceRequest(ResourceRequest request) async {
    final database = await db.database;
    return await database.insert(
      'resource_requests',
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ResourceRequest>> getAll() async {
    final database = await db.database;
    final List<Map<String, Object?>> result =
        await database.query('resource_requests');

    return [
      for (final {
        'id': id as int,
        'resource_type': resourceType as String,
        'quantity': quantity as int,
        'note': note as String,
        'requester_id': requesterId as String,
        'status': status as String,
        'timestamp': timestamp as String
      } in result)
        ResourceRequest(
          id: id,
          resourceType: resourceType,
          quantity: quantity,
          note: note,
          requesterId: requesterId,
          status: status,
          timestamp: timestamp,
        )
    ];
  }

  Future<void> updateResourceRequest(ResourceRequest request) async {
    final database = await db.database;
    await database.update(
      'resource_requests',
      request.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<void> deleteResourceRequest(int id) async {
    final database = await db.database;
    await database.delete(
      'resource_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
