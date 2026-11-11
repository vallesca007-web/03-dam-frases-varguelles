import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/frase.dart';

class FrasesDb {
  FrasesDb._();
  static final FrasesDb instancia = FrasesDb._();
  static const _nombreArchivo = 'misfrases.db';
  static const _tabla = 'frases';
  Database? _db;

  // devuelve la bd abierta (la abre solo la primera vez). Pdd: Singleton
  Future<Database> get _database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tabla (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            frase TEXT NOT NULL,
            autor TEXT NOT NULL
          )
        ''');
      },
    );
  }

// guarda y devuelve el id
Future<int> insertar(Frase frase) async {
  final db = await _database;
  return db.insert(_tabla, frase.toMap());
}

// lee todas las frase de manera descendente
Future<List<Frase>> obtenerTodas() async {
  final db = await _database;
  final filas = await db.query(_tabla, orderBy: 'id DESC');
  return filas.map(Frase.fromMap).toList();
}

// modifica usando el id
Future<int> actualizar(Frase frase) async {
  final db = await _database;
  return db.update(
    _tabla,
    frase.toMap(),
    where: 'id = ?',
    whereArgs: [frase.id],
  );
}

// elimina la frase con el id
Future<int> eliminar(int id) async {
  final db = await _database;
  return db.delete(_tabla, where: 'id = ?', whereArgs: [id]);
}
}