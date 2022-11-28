import 'package:psqlite/src/condition_db.dart';

/// Represents a filter that can be used in PSQlite to query SQLite with filters.
/// Underneath, this will generate an SQL query with a Where clause.
class FilterDb {
  /// The column name.
  final String _field;

  /// The value to filter.
  final dynamic _value;

  /// The type of filter condition.
  final ConditionDb _conditionDb;

  /// Create a Filter passing as parameter [field] the name of the column, [value] the value to filter and [conditionDb] the condition of the filter.
  FilterDb(String field, dynamic value, ConditionDb conditionDb)
      : _field = field,
        _value = value,
        _conditionDb = conditionDb;

  /// Generate SQL linked to this filter.
  String getSqlWhere() => '$_field ${_conditionDb.getSqlCondition()} ?';

  /// Return the column name.
  String getField() => _field;

  /// Return the value to filter.
  dynamic getValue() =>
      (_conditionDb == ConditionDb.contains) ? '%$_value%' : _value;
}
