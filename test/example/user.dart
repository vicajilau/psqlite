import 'package:psqlite/psqlite.dart';

class User extends ObjectStored {
  final String _id;
  String _name;
  String _lastName;

  User(this._id, this._name, this._lastName);

  User.fromJson(this._id, this._name, this._lastName);

  String getId() => _id;
  String getName() => _name;
  String getLastName() => _lastName;

  void setName(String name) => _name = name;
  void setLastName(String lastName) => _lastName = lastName;

  @override
  String toString() => 'User{_id: $_id, name: $_name, _lastName: $_lastName}';

  // The keys must correspond to the names of the columns in the database.
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'lastName': _lastName,
    };
  }

  @override
  String getPrimaryKey() => _id;

  @override
  bool operator ==(Object other) {
    if (other is! User) return false;
    if (_id != other._id) return false;
    if (_name != other._name) return false;
    if (_lastName != other._lastName) return false;
    return true;
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + _id.hashCode;
    result = 37 * result + _name.hashCode;
    result = 37 * result + _lastName.hashCode;
    return result;
  }
}
