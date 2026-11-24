import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/resenia.dart';

class RecetaDb {
  RecetaDb._();
  static final RecetaDb instancia = RecetaDb._();
  static const _nombreArchivo = 'misrecenias.db';
  static const _tablaResenias = 'resenias';
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: 2,
      onCreate: (db, version) => _crearTablaResenias(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _crearTablaResenias(db);
        }
      },
    );
  }

  Future<void> _crearTablaResenias(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE $_tablaResenias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recetaId INTEGER NOT NULL,
        texto TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertarResenia(Resenia resenia) async {
    final db = await _database;
    return db.insert(_tablaResenias, resenia.toMap()..remove('id'));
  }

  Future<List<Resenia>> obtenerResenias(int recetaId) async {
    final db = await _database;
    final filas = await db.query(
      _tablaResenias,
      where: 'recetaId = ?',
      whereArgs: [recetaId],
      orderBy: 'fecha DESC, id DESC',
    );
    return filas.map(Resenia.fromMap).toList();
  }
}
