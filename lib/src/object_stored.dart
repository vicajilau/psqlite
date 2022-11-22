/// All objects that intend to be stored in SQLite databases should extend the ObjectStored class.
abstract class ObjectStored {
  /// The value linked with the primary key column name of the database.
  String getPrimaryKey();

  /// The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap();
}
