import 'field_type_db.dart';

/// Defines a column of a database table.
/// A TableDb object will be made up of a collection of ColumnDb objects.
class ColumnDb {
  /// The name of the database column.
  final String fieldName;

  /// The type of data that the database column contains.
  final FieldTypeDb fieldType;

  /// Indicates if this column is primary key.
  final bool isPrimaryKey;

  ColumnDb(
      {this.isPrimaryKey = false,
      required this.fieldName,
      required this.fieldType});

  @override
  String toString() {
    String description = '$fieldName ${fieldType.getName()}';
    if (isPrimaryKey) {
      description += ' PRIMARY KEY';
    }
    return description;
  }
}
