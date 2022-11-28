import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../psqlite.dart';

/// Encapsulates a database that is made up of a [_table] and a [_dbName].
class PSQLite {
  /// The name of the database. This will be used as the file name.
  String _dbName;

  /// The [_table] of the database. It will be used for the creation, update and remove of the database.
  TableDb _table;

  /// Set the version. This executes the onCreate function and provides a path to perform database upgrades and downgrades.
  int _version;

  /// The encapsulation database (The database itself).
  Database? _database;

  /// Used to create unit tests. Defaults to false.
  bool _isMocked;

  /// Build the necessary database using lazy programming.
  Future<Database> _getDatabase() async {
    _database ??= (_isMocked)
        ? await _mockedDataBase()
        : _database = await _initializeDB();
    return _database!;
  }

  TableDb getTable() => _table;
  void setTable(TableDb table) => _table = table;

  int getVersion() => _version;

  /// Set the version of the database.
  void setVersion(int version) => _version = version;

  /// Indicates if the database should is mocked.
  bool getIsMocked() => _isMocked;

  /// Set if the database should be mocked in memory or real.
  void setMocked(bool mocked) {
    _isMocked = mocked;
    _database = null; // This forces the instance to be reinitialized properly.
  }

  /// Get the database name.
  String getDbName() => _dbName;

  /// Modify the name of the database.
  void setDbName(String name) => _dbName = name;

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
    final filter = FilterDb(
        _table.getPrimaryColumn().getName(), primaryKey, ConditionDb.equal);
    final response =
        await db.query(_table.getName(), where: filter.getSqlWhere(),
            // Prevent SQL injection.
            whereArgs: [primaryKey]);
    if (response.isEmpty) {
      return null;
    } else {
      return response.first;
    }
  }

  List<dynamic>? _getWhereFilters(List<FilterDb>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }
    List<dynamic> result = [];

    for (int i = 0; i < filters.length; i++) {
      final value = filters[i].getValue();
      result.add(value);
    }
    return result;
  }

  String? _getWhereSentence(List<FilterDb>? filters) {
    String sentence = '';
    if (filters == null || filters.isEmpty) {
      return null;
    }
    for (int i = 0; i < filters.length; i++) {
      if (!_table.existColumnWith(filters[i].getField())) {
        throw Exception('The ${filters[i].getField()} does not exist.');
      }
      sentence += filters[i].getSqlWhere();
      if (i != filters.length - 1) {
        sentence += ' AND ';
      }
    }
    return sentence;
  }

  /// A method that retrieves all the objects from the current table.
  Future<List<Map<String, dynamic>>> getElementsWhere(
      List<FilterDb>? filter) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final response = await db.query(_table.getName(),
        where: _getWhereSentence(filter),
        // Prevent SQL injection.
        whereArgs: _getWhereFilters(filter));
    if (response.isEmpty) {
      return [];
    } else {
      return response;
    }
  }

  /// Update the given object in the current table.
  Future<void> updateElement(ObjectStored object) async {
    final db = await _getDatabase();
    final filter = FilterDb(_table.getPrimaryColumn().getName(),
        object.getPrimaryKey(), ConditionDb.equal);
    await db.update(
      _table.getName(),
      object.toMap(),
      where: filter.getSqlWhere(),
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
  }

  /// Remove the given object in the current table.
  Future<void> deleteElement(ObjectStored object) async {
    final db = await _getDatabase();
    final filter = FilterDb(_table.getPrimaryColumn().getName(),
        object.getPrimaryKey(), ConditionDb.equal);
    await db.delete(
      _table.getName(),
      where: filter.getSqlWhere(),
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
