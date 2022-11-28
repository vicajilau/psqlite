import 'package:psqlite/src/iterable_extension.dart';

import 'column_db.dart';

/// Defines a table in a database.
/// It consists of a collection of ColumnDb objects and a table name.
class TableDb {
  /// The collection of columns that make up the table.
  final List<ColumnDb> _columns;

  /// The name of the table.
  final String _name;

  /// Create a table with a [name] and a list of empty columns.
  TableDb(this._name) : _columns = [];

  /// Check if a list of column has unique names.
  static bool areUniqueColumnNames(List<ColumnDb> columns) =>
      columns.toSet().length == columns.length;

  /// Create a table with a [name] and a list of [columns].
  TableDb.create({required String name, required List<ColumnDb> columns})
      : _name = name,
        _columns = columns,
        assert(areUniqueColumnNames(columns));

  /// Add a [columnDb] in the column list.
  /// Throw a exception if the name of the column already exist.
  void addColumn(ColumnDb columnDb) {
    if (!_columns.contains(columnDb)) {
      _columns.add(columnDb);
    } else {
      throw Exception('Column already exist in the table. $columnDb');
    }
  }

  /// Replace a [newColumn] with the first column that satisfy [whereFunction].
  void replaceColumn(
      ColumnDb newColumn, bool Function(ColumnDb element) whereFunction) {
    int index = _columns.indexWhere(whereFunction);
    if (index != -1) {
      _columns.removeAt(index);
      _columns.insert(index, newColumn);
    }
  }

  /// Search and remove all columns from this table that satisfy [whereFunction].
  void searchColumnAndRemoveIt(bool Function(ColumnDb element) whereFunction) =>
      _columns.removeWhere(whereFunction);

  /// Remove the [column] passed.
  bool removeColumn(ColumnDb column) => _columns.remove(column);

  /// Return all columns from this table.
  List<ColumnDb> getColumns() => _columns;
  String getName() => _name;

  /// Check if the table make no sense.
  void checkInconsistentTable() {
    if (_columns.countWhere((column) => column.getName().isEmpty) > 0) {
      throw Exception(
          'Table $_name has inconsistencies. There is/are empty column names.');
    } else if (_columns.countWhere((column) => column.isPrimaryKey()) == 0) {
      throw Exception(
          'Table $_name has inconsistencies. There is no any primary key column.');
    } else if (_columns.countWhere((column) => column.isPrimaryKey()) > 1) {
      throw Exception(
          'Table $_name has inconsistencies. There are multiple primary keys columns.');
    }
  }

  /// Return the primary key column of the table.
  ColumnDb getPrimaryColumn() =>
      _columns.firstWhere((column) => column.isPrimaryKey());

  /// Return the to create this table based on the columns it currently has.
  String getCreateDbRequest() {
    checkInconsistentTable();
    String query = 'CREATE TABLE $_name(';
    for (int i = 0; i < _columns.length; i++) {
      final column = _columns[i];
      query += column.toString();
      if (i != _columns.length - 1) {
        query += ', ';
      } else {
        query += ')';
      }
    }
    return query;
  }

  /// Return if there is a column with that name.
  bool existColumnWith(String name) {
    try {
      _columns.firstWhere((column) => column.getName() == name);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  String toString() => 'TableDb{_name: $_name, _columns: $_columns}';
}
