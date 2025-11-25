import 'package:beacon/model/db.helper.dart';
import 'package:beacon/model/data/UserProfile.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class UserProfileDao {
  final db = DatabaseHelper.instance;

  Future<int> insertUserProfile(UserProfile profile) async {
    final database = await db.database;
    return await database.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserProfile>> getAll() async {
    final database = await db.database;
    final List<Map<String, Object?>> result =
        await database.query('user_profile');

    return [
      for (final {
        'id': id as int,
        'device_id': deviceId as String,
        'name': name as String,
        'phone': phone as String,
        'blood_type': bloodType as String,
        //'emergency_contact_name': emergencyContactName as String,
        //'emergency_contact_phone': emergencyContactPhone as String,
        'created_at': createdAt as String,
        'updated_at': updatedAt as String,
        'image_path': imagePath as String
      } in result)
        UserProfile(
          id: id,
          deviceId: deviceId,
          name: name,
          phone: phone,
          bloodType: bloodType,
          //emergencyContactName: emergencyContactName,
          //emergencyContactPhone: emergencyContactPhone,
          imagePath: imagePath,
          createdAt: createdAt,
          updatedAt: updatedAt,
        )
    ];
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final database = await db.database;
    await database.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<void> deleteUserProfile(int id) async {
    final database = await db.database;
    await database.delete(
      'user_profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
