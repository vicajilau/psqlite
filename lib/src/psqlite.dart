import 'dart:async';

import 'package:path/path.dart';
import 'package:psqlite/src/table_db.dart';
import 'package:sqflite/sqflite.dart';

import 'object_stored.dart';

/// Encapsulates a database that is made up of a [table] and a [dbName].
class PSQLite {
  /// The [name] of the database. This will be used as the file name.
  final String dbName;

  /// The [table] of the database. It will be used for the creation, update and remove of the database.
  final TableDb table;

  /// Set the version. This executes the onCreate function and provides a path to perform database upgrades and downgrades.
  final int version;

  /// The encapsulation database (The database itself).
  Database? _database;

  /// Used to create unit tests. Defaults to false.
  bool isMocked;

  /// Build the necessary database using lazy programming.
  Future<Database> _getDatabase() async {
    _database ??= (isMocked)
        ? await _mockedDataBase()
        : _database = await _initializeDB();
    return _database!;
  }

  /// Constructor for the database.
  PSQLite({required this.table, this.version = 1, this.isMocked = false})
      : dbName = '${table.getName()}.db';

  /// Create a mocked database.
  Future<Database> _mockedDataBase() async {
    return await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(table.getCreateDbRequest());
    });
  }

  /// Create a real database.
  Future<Database> _initializeDB() async {
    // Open the database and store the reference.
    return await openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          table.getCreateDbRequest(),
        );
      },
      version: version,
    );
  }

  /// Define a function that inserts a Object into the database
  Future<void> insertElement(ObjectStored object,
      [ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace]) async {
    final db = await _getDatabase();
    await db.insert(
      table.getName(),
      object.toMap(),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// A method that retrieves all the objects from the current table.
  Future<List<Map<String, dynamic>>> getElements() async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    return await db.query(table.getName());
  }

  /// A method that retrieves all the objects from the current table.
  Future<Map<String, dynamic>?> getElementBy(String id) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final response = await db.query(table.getName(),
        where: '${table.getPrimaryColumn().fieldName} = ?',
        // Prevent SQL injection.
        whereArgs: [id]);
    if (response.isEmpty) {
      return null;
    } else {
      return response.first;
    }
  }

  /// Update the given object in the current table.
  Future<void> updateElement(ObjectStored object) async {
    final db = await _getDatabase();
    await db.update(
      table.getName(),
      object.toMap(),
      where: '${table.getPrimaryColumn().fieldName} = ?',
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
  }

  /// Remove the given object in the current table.
  Future<void> deleteElement(ObjectStored object) async {
    final db = await _getDatabase();
    await db.delete(
      table.getName(),
      where: '${table.getPrimaryColumn().fieldName} = ?',
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
  }

  /// Remove all elements in the current table.
  Future<void> clearTable() async {
    final db = await _getDatabase();
    await db.delete(table.getName());
  }
}
