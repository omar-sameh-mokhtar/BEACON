import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/Message.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';


class MessageDao {
  final db = DatabaseHelper.instance;

  Future<int> insertMessage(Message message) async {
    final database = await db.database;
    return await database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,);
  }

  Future<List<Message>> getAll() async {
    final database = await db.database;
    final List<Map<String, Object?>> result = await database.query('messages');

    return result.map((map) => Message.fromMap(map)).toList();
  }

  Future<void> updateMessage(Message message) async {
    final database = await db.database;
    await database.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> deleteMessage(int id) async {
    final database = await db.database;
    await database.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
