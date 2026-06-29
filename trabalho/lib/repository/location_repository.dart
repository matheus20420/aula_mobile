import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:trabalho/models/location_model.dart';

class LocationRepository {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'location.db');
    return openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE location (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL, longitude REAL)',
      );
    });
  }

  static Future<LocationModel?> getLocation() async {
    final database = await db;
    final result = await database.query('location', limit: 1);
    if (result.isEmpty) return null;
    return LocationModel.fromJson(result.first);
  }

  static Future<void> saveOrUpdateLocation(LocationModel location) async {
    final database = await db;
    final existing = await getLocation();
    if (existing == null) {
      await database.insert('location', location.toJson());
    } else if (existing.latitude != location.latitude ||
        existing.longitude != location.longitude) {
      await database.update(
        'location',
        location.toJson(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
