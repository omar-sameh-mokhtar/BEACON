import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  final secureStorage = const FlutterSecureStorage();

  Future<String> _getDbPassword() async {
    String? password = await secureStorage.read(key: 'db_key');

    if (password == null) {
      password = DateTime.now().millisecondsSinceEpoch.toString();
      await secureStorage.write(key: 'db_key', value: password);
    }

    return password;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'beacon.db');
    final password = await _getDbPassword();

    WidgetsFlutterBinding.ensureInitialized();

    return await openDatabase(
      path,
      password: password,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        device_id TEXT,
        name TEXT,
        phone TEXT,
        blood_type TEXT,
        '''
        //emergency_contact_name TEXT,
        //emergency_contact_phone TEXT,
        '''
        created_at TEXT,
        updated_at TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE connected_devices (
        id INTEGER PRIMARY KEY,
        device_id TEXT,
        name TEXT,
        last_seen TEXT,
        connection_status TEXT,
        signal_strength INTEGER,
        first_discovered TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY,
        sender_device_id TEXT,
        message_type TEXT,
        content TEXT,
        timestamp TEXT,
        delivered INTEGER,
      )
    ''');

    await db.execute('''
      CREATE TABLE resource_requests (
        id INTEGER PRIMARY KEY,
        resource_type TEXT,
        quantity INTEGER,
        note TEXT,
        requester_id TEXT,
        status TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
