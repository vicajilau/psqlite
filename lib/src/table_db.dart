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

  /// Create a table with a [name] and a list of [columns].
  TableDb.create({required String name, required List<ColumnDb> columns})
      : _name = name,
        _columns = columns;

  /// Add a [columnDb] in the column list.
  void addColumn(ColumnDb columnDb) => _columns.add(columnDb);

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
  void removeColumn(ColumnDb column) => _columns.remove(column);

  /// Return all columns from this table.
  List<ColumnDb> getColumns() => _columns;
  String getName() => _name;

  /// Check if the table make no sense.
  bool isInconsistentTable() {
    int numberOfPrimaryKeys = 0;
    bool thereIsEmptyColumnName = false;
    for (var element in _columns) {
      if (element.isPrimaryKey) {
        numberOfPrimaryKeys++;
      }
      if (element.fieldName.isEmpty) {
        thereIsEmptyColumnName = true;
      }
    }
    return numberOfPrimaryKeys != 1 || thereIsEmptyColumnName;
  }

  /// Return the primary key column of the table.
  ColumnDb getPrimaryColumn() =>
      _columns.firstWhere((element) => element.isPrimaryKey);

  /// Return the to create this table based on the columns it currently has.
  String getCreateDbRequest() {
    if (!isInconsistentTable()) {
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
    } else {
      throw Exception(
          'Table $_name has inconsistencies (empty names, multiples primary keys or none');
    }
  }
}
