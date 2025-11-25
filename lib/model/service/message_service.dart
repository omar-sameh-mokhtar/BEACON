import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/Message.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';


class UserProfileDao {
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

    return [
      for(final {'id': id as int, 'sender_device_id': senderDeviceId as String, 'content': content as String, 'timestamp': timestamp as String, 'delivered': delivered as int} in result)
        Message(
          id: id,
          senderDeviceId: senderDeviceId,
          content: content,
          timestamp: timestamp,
          delivered: delivered,
        )
    ];
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
