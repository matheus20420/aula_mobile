import 'conn.dart';
import 'usuario.dart';

class UsuarioDao {
  static const String table = 'usuarios';

  static Future<int> insert(Usuario usuario) async {
    final db = await ConnectionDb.instance.database;
    return await db.insert(table, usuario.toMap());
  }

  static Future<List<Usuario>> getAll() async {
    final db = await ConnectionDb.instance.database;
    final result = await db.query(table, orderBy: 'id DESC');
    return result.map((row) => Usuario.fromMap(row)).toList();
  }

  static Future<int> update(Usuario usuario) async {
    final db = await ConnectionDb.instance.database;
    return await db.update(
      table,
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await ConnectionDb.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
