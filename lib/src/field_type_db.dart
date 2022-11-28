/// Defines the type of the value of a column of a table in a database.
/// SQLite does not have a separate Boolean storage class.
/// Instead, Boolean values are stored as integers 0 (false) and 1 (true).
enum FieldTypeDb {
  /// The value is a signed integer, stored in 0, 1, 2, 3, 4, 6, or 8 bytes depending on the magnitude of the value.
  integer,

  /// The value is a floating point value, stored as an 8-byte IEEE floating point number.
  real,

  /// The value is a text string, stored using the database encoding (UTF-8, UTF-16BE or UTF-16LE).
  text,

  /// The value is a blob of data, stored exactly as it was input.
  blob,
}

extension CustomFieldTypeDb on FieldTypeDb {
  /// Return SQL column type related.
  String getName() {
    return name.toUpperCase();
  }
}
