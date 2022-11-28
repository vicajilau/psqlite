import 'package:psqlite/src/condition_db.dart';

class FilterDb {
  final String _field;
  final dynamic _value;
  final ConditionDb _conditionDb;

  FilterDb(String field, dynamic value, ConditionDb conditionDb)
      : _field = field,
        _value = value,
        _conditionDb = conditionDb;

  String getSqlWhere() => '$_field ${_conditionDb.getSqlCondition()} ?';

  String getField() => _field;

  dynamic getValue() =>
      (_conditionDb == ConditionDb.contains) ? '%$_value%' : _value;
}
