import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';


class ResourceDao {
  final _db = DatabaseHelper.instance;


  Future<void> addResource(Resource resource) async {
    final db = await _db.database;
    await db.insert(
      'resources',
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Resource>> getAllResources() async {
    final db = await _db.database;
    final result = await db.query('resources');
    return result.map(Resource.fromMap).toList();
  }


  Future<void> updateResource(Resource resource) async {
    final db = await _db.database;
    await db.update(
      'resources',
      resource.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  Future<void> requestResource(Resource resource) async {
    final db = await _db.database;
    await db.update(
      'resources',
      {
        'status': 'requested',
        'is_requested': 1,
        'timestamp': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  Future<void> upsertResource(Resource resource) async {
    final db = await _db.database;

    await db.insert(
      'resources',
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> deleteResource(int id) async {
    final db = await _db.database;
    await db.delete(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> ClearResources( String owner ) async {
    debugPrint("--------------------------------[DEBUG] Clearing resources from db ++++++++++++++++++++++++++++++"+owner);
    for ( final resource in await getAllResources() ){
      if ( resource.owner != owner ){
        debugPrint("--------------------------------[DEBUG] Deleting resource from db +++++++++++++++++++++++++++++"+owner);
        await deleteResource(resource.id);
      }
    }

  }


}

