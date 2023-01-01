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

  /// Return the table related in the current database.
  TableDb getTable() => _table;

  /// Set a new table in the current database.
  void setTable(TableDb table) => _table = table;

  /// Return the version of the database.
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

  /// Define a function that inserts a Object into the table.
  ///
  /// [object] is the ObjectStored object to insert. Optionally,
  /// [conflictAlgorithm] is the algorithm in case of conflict,
  /// by default the oldest is replaced by the newest.
  ///
  /// ```
  /// await db.insertElement(user);
  /// ```
  Future<void> insertElement(ObjectStored object,
      [ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace]) async {
    final db = await _getDatabase();
    await db.insert(
      _table.getName(),
      object.toMap(),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// A method that returns a table element based on its primary key.
  ///
  /// [primaryKey] is the primary key value to search for.
  ///
  /// Returns the element associated with that primary key, or null if not found:
  /// ```
  ///  final user = await db.getElementBy("4");
  /// ```
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

  /// Retrieves all elements from the table that match the list of filters.
  /// An empty filter listing will return all the objects from the current table.
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing empty
  /// will delete all rows.
  ///
  /// Returns all items matching the filters:
  /// ```
  /// final minorElements = await db.getElements(where: [FilterDb('age', 18, ConditionDb.less)]);
  /// ```
  ///
  /// Returns all items in the table:
  /// ```
  /// final allElements = await db.getElements();
  /// ```
  Future<List<Map<String, dynamic>>> getElements(
      { List<FilterDb> where = const []}) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final response = await db.query(_table.getName(),
        where: _getWhereSentence(where),
        // Prevent SQL injection.
        whereArgs: _getWhereArgs(where));
    if (response.isEmpty) {
      return [];
    } else {
      return response;
    }
  }

  /// Update the given object in the current table.
  ///
  /// [object] is the ObjectStored object to update.
  ///
  /// ```
  /// await db.updateElement(user);
  /// ```
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
  ///
  /// [object] is the ObjectStored object to delete.
  ///
  /// Returns the element was deleted or not.
  /// ```
  /// bool result = await db.deleteElement(user);
  /// ```
  Future<bool> deleteElement(ObjectStored object) async {
    final db = await _getDatabase();
    final filter = FilterDb(_table.getPrimaryColumn().getName(),
        object.getPrimaryKey(), ConditionDb.equal);
    final numberOfElements = await db.delete(
      _table.getName(),
      where: filter.getSqlWhere(),
      // Prevent SQL injection.
      whereArgs: [object.getPrimaryKey()],
    );
    return numberOfElements >= 1;
  }

  /// Removes all elements from the table that match the list of filters.
  /// An empty filter listing will cause the table to be completely emptied.
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing empty
  /// will delete all rows.
  ///
  /// Returns the number of rows affected.
  /// ```
  /// int count = await db.deleteElements(where: [FilterDb('age', 18, ConditionDb.less)]);
  /// ```
  Future<int> deleteElements({List<FilterDb> where = const []}) async {
    // Query the table for all The Elements.
    final db = await _getDatabase();
    final numberOfElements = await db.delete(_table.getName(),
        where: _getWhereSentence(where),
        // Prevent SQL injection.
        whereArgs: _getWhereArgs(where));
    return numberOfElements;
  }

  /// Remove all elements in the current table.
  Future<void> clearTable() async {
    final db = await _getDatabase();
    await db.delete(_table.getName());
  }
}

/// Private PSQLite operations.
extension PrivatePSQLite on PSQLite {
  /// Build the necessary database using lazy programming.
  Future<Database> _getDatabase() async {
    _database ??= (_isMocked)
        ? await _mockedDataBase()
        : _database = await _initializeDB();
    return _database!;
  }

  /// Function that gets internally the values or arguments of the where statement
  /// If the list of filters is empty, it will return null instead.
  List<dynamic>? _getWhereArgs(List<FilterDb>? filters) {
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

  /// Function that gets internally the WHERE part of the SQL statement from the list of filters.
  /// If the list of filters is empty, it will return null instead.
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
}