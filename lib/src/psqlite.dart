import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../psqlite.dart';

/// Encapsulates a database that is made up of a [_table] and a [_dbName].
class PSQLite {
  /// The [name] of the database. This will be used as the file name.
  final String _dbName;

  /// The [_table] of the database. It will be used for the creation, update and remove of the database.
  final TableDb _table;

  /// Set the version. This executes the onCreate function and provides a path to perform database upgrades and downgrades.
  final int _version;

  /// The encapsulation database (The database itself).
  Database? _database;

  /// Used to create unit tests. Defaults to false.
  final bool _isMocked;

  /// Build the necessary database using lazy programming.
  Future<Database> _getDatabase() async {
    _database ??= (_isMocked)
        ? await _mockedDataBase()
        : _database = await _initializeDB();
    return _database!;
  }

  TableDb getTable() => _table;
  int getVersion() => _version;
  bool getIsMocked() => _isMocked;

  /// Constructor for the database.
  PSQLite({required TableDb table, int version = 1, bool isMocked = false})
      : _table = table,
        _version = version,
        _isMocked = isMocked,
        _dbName = '${table.getName()}.db';

  /// Create a mocked database.
  Future<Database> _mockedDataBase() async {
    return await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db.execute(_table.getCreateDbRequest());
    });
  }

  /// Create a real database.
  Future<Database> _initializeDB() async {
    // Open the database and store the reference.
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          _table.getCreateDbRequest(),
        );
      },
      version: _version,
    );
  }

  /// Define a function that inserts a Object into the database
  Future<void> insertElement(ObjectStored object,
      [ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace]) async {
    final db = await _getDatabase();
    await db.insert(
      _table.getName(),
      object.toMap(),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// A method that retrieves all the objects from the current table.
  Future<List<Map<String, dynamic>>> getElements() async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    return await db.query(_table.getName());
  }

  /// A method that retrieves all the objects from the current table.
  Future<Map<String, dynamic>?> getElementBy(String primaryKey) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final response = await db.query(_table.getName(),
        where: '${_table.getPrimaryColumn().fieldName} = ?',
        // Prevent SQL injection.
        whereArgs: [primaryKey]);
    if (response.isEmpty) {
      return null;
    } else {
      return response.first;
    }
  }

  List<dynamic>? _getWhereFilters(Map<ColumnDb, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }
    List<dynamic> result = [];
    filters.values.map((e) {
      result.add(e.fieldName);
    });
    return result;
  }

  String? _getWhereSentence(Map<ColumnDb, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }

    String sentence = '';

    for (int i = 0; i < filters.length; i++) {
      final value = filters[i];

      sentence += '$value = ?';

      if (i != filters.length - 1) {
        sentence += ' AND ';
      }
    }

    return sentence;
  }

  /// A method that retrieves all the objects from the current table.
  Future<List<Map<String, dynamic>>> getElementsWhere(
      Map<ColumnDb, dynamic>? filters) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final response = await db.query(_table.getName(),
        where: _getWhereSentence(filters),
        // Prevent SQL injection.
        whereArgs: _getWhereFilters(filters));
    if (response.isEmpty) {
      return [];
    } else {
      return response;
    }
  }

  /// Update the given object in the current table.
  Future<void> updateElement(ObjectStored object) async {
    final db = await _getDatabase();
    await db.update(
      _table.getName(),
      object.toMap(),
      where: '${_table.getPrimaryColumn().fieldName} = ?',
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
  }

  /// Remove the given object in the current table.
  Future<void> deleteElement(ObjectStored object) async {
    final db = await _getDatabase();
    await db.delete(
      _table.getName(),
      where: '${_table.getPrimaryColumn().fieldName} = ?',
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
  }

  /// Remove all elements in the current table.
  Future<void> clearTable() async {
    final db = await _getDatabase();
    await db.delete(_table.getName());
  }
}
