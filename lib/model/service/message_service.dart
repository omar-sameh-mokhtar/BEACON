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

  Future<List<Message>> getChatHistory(String myId, String peerId) async {
    final database = await db.database;
    
    final List<Map<String, Object?>> result = await database.query(
      'messages',
      where: '(sender_device_id = ? AND receiver_device_id = ?) OR (sender_device_id = ? AND receiver_device_id = ?) OR (receiver_device_id = ?)',
      
      whereArgs: [myId, peerId, peerId, myId, "ALL"],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => Message.fromMap(map)).toList();
  }

  Future<Message?> getLastMessageForPeer(String myId, String peerId) async {
    final database = await db.database;
    final List<Map<String, Object?>> result = await database.query(
      'messages',
      where: '(sender_device_id = ? AND receiver_device_id = ?) OR (sender_device_id = ? AND receiver_device_id = ?) OR'
      "(receiver_device_id = ?)",
      whereArgs: [myId, peerId, peerId, myId, "ALL"],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Message.fromMap(result.first);
  }
}
