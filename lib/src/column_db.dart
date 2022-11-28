import 'package:psqlite/psqlite.dart';

import 'field_type_db.dart';

/// Defines a column of a database table.
/// A TableDb object will be made up of a collection of ColumnDb objects.
class ColumnDb {
  /// The name of the database column.
  final String _name;

  /// The type of data that the database column contains.
  final FieldTypeDb _type;

  /// Indicates if this column is primary key.
  final bool _isPrimaryKey;

  ColumnDb(
      {bool isPrimaryKey = false,
      required String name,
      required FieldTypeDb type})
      : _isPrimaryKey = isPrimaryKey,
        _name = name,
        _type = type;

  /// Return the name of the database column.
  String getName() => _name;

  /// Return the type of data that the database column contains.
  FieldTypeDb getType() => _type;

  /// Return if this column is primary key.
  bool isPrimaryKey() => _isPrimaryKey;

  @override
  String toString() {
    String description = '$_name ${_type.getName()}';
    if (_isPrimaryKey) {
      description += ' PRIMARY KEY';
    }
    return description;
  }

  @override
  bool operator ==(Object other) {
    if (other is! ColumnDb) return false;
    if (getName().toUpperCase() != other.getName().toUpperCase()) return false;
    return true;
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + _name.hashCode;
    result = 37 * result + _type.hashCode;
    result = 37 * result + _isPrimaryKey.hashCode;
    return result;
  }
}
