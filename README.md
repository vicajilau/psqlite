# PSQLite

[![pub package](https://img.shields.io/pub/v/sqflite.svg)](https://pub.dev/packages/psqlite)

Easily manipulate sqlite databases in Dart using this package. The designed objects structure is as follows:
* [TableDb][]: Defines a table in a database. It consists of a collection of ColumnDb objects and a table name.
* [ColumnDb][]: Defines a column of a database table. A TableDb object will be made up of a collection of ColumnDb objects.
* [FieldTypeDb][]: Defines the type of the value of a column of a table in a database. SQLite does not have a separate Boolean storage class. Instead, Boolean values are stored as integers 0 (false) and 1 (true).
* [ObjectStored][]: All objects that intend to be stored in SQLite databases should extend the ObjectStored class.
* [PSQLite][]: Encapsulates a database that is made up of a TableDb and a database name.
* [FilterDb][]: Defining a filter to make requests to PSQLite will allow us not to have to bring you all the SQLite fields and filter manually, optimizing SQLite queries through the use of filters.
* [ConditionDb][]: Allows you to define the type of condition of a filter.

## Usage example

In the following example you will see how to create a user database. 

Import `psqlite.dart`

```dart
import 'package:psqlite/psqlite.dart';
```

### Create a User 
User class that represents the object that we are going to store. 
Any object that is going to be ported to SQLite requires extending the ObjectStored class. 
This will force us to override the toMap and getPrimaryKey methods.
```dart
import 'package:psqlite/psqlite.dart';

class User extends ObjectStored {
  final String _id;
  String _name;
  String _lastName;
  int _age;

  User(this._id, this._name, this._lastName, this._age);

  User.fromJson(this._id, this._name, this._lastName, this._age);

  String getId() => _id;
  String getName() => _name;
  String getLastName() => _lastName;
  int getAge() => _age;

  void setName(String name) => _name = name;
  void setLastName(String lastName) => _lastName = lastName;
  void setAge(int age) => _age = age;

  @override
  String toString() =>
      'User{_id: $_id, _name: $_name, _lastName: $_lastName, _age: $_age}';

  // The keys must correspond to the names of the columns in the database.
  @override
  Map<String, dynamic> toMap() {
    return {'id': _id, 'name': _name, 'lastName': _lastName, 'age': _age};
  }

  @override
  String getPrimaryKey() => _id;

  @override
  bool operator ==(Object other) {
    if (other is! User) return false;
    if (_id != other._id) return false;
    if (_name != other._name) return false;
    if (_lastName != other._lastName) return false;
    if (_age != other._age) return false;
    return true;
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + _id.hashCode;
    result = 37 * result + _name.hashCode;
    result = 37 * result + _lastName.hashCode;
    result = 37 * result + _age.hashCode;
    return result;
  }
}
```

### Create a User Storage Service 

The easiest way to encapsulate the data persistence of the User object that we have created is by creating a wrapper service.
Inside we will create the columns of the table and the name of the database.
The mockedDatabase parameter will allow us to perform unit tests on our service.
For simplicity and in order to create [FilterDb][] type objects, the parameterized use of the column names is recommended. 
In this case, an enumerator has been used for this example called UserColumnName.

```dart
import 'package:psqlite/psqlite.dart';

import 'user.dart';

enum UserColumnName { id, name, lastName, age }

class UserStorageService {
  static final shared = UserStorageService.init();
  late PSQLite _database;
  final _tableName = 'users';

  UserStorageService.init({bool mockedDatabase = false}) {
    List<ColumnDb> columns = [
      ColumnDb(
          name: UserColumnName.id.name,
          type: FieldTypeDb.text,
          isPrimaryKey: true),
      ColumnDb(name: UserColumnName.name.name, type: FieldTypeDb.text),
      ColumnDb(name: UserColumnName.lastName.name, type: FieldTypeDb.text),
      ColumnDb(name: UserColumnName.age.name, type: FieldTypeDb.integer)
    ];
    final table = TableDb.create(name: _tableName, columns: columns);
    _database = PSQLite(table: table, isMocked: mockedDatabase);
  }

  PSQLite getDatabase() => _database;

  Future<void> addUser(User user) async {
    return await _database.insertElement(user);
  }

  Future<void> updateUser(User user) async {
    return await _database.updateElement(user);
  }

  Future<void> removeUser(User user) async {
    return await _database.deleteElement(user);
  }

  Future<User?> getUser(String id) async {
    final response = await _database.getElementBy(id);
    if (response != null) {
      return User(
          response[UserColumnName.id.name],
          response[UserColumnName.name.name],
          response[UserColumnName.lastName.name],
          response[UserColumnName.age.name]);
    }
    return null;
  }

  Future<List<User>> getListOfUsers() async {
    final maps = await _database.getElements();
    return List.generate(maps.length, (i) {
      return User(
          maps[i][UserColumnName.id.name],
          maps[i][UserColumnName.name.name],
          maps[i][UserColumnName.lastName.name],
          maps[i][UserColumnName.age.name]);
    });
  }

  Future<List<User>> getListOfUsersBy(List<FilterDb>? filters) async {
    final maps = await _database.getElementsWhere(filters);
    return List.generate(maps.length, (i) {
      return User(
          maps[i][UserColumnName.id.name],
          maps[i][UserColumnName.name.name],
          maps[i][UserColumnName.lastName.name],
          maps[i][UserColumnName.age.name]);
    });
  }

  Future<void> removeAll() async {
    await _database.clearTable();
  }
}
```

### Usages
Now we can make requests to our User Storage Service from anywhere in the application. 

#### Create a User Storage Service
You can create a single object:
```dart
final storageService = UserStorageService.init();
```

Or you can get the shared instance with singleton pattern:
```dart
final storageService = UserStorageService.shared;
```

#### Add a new User in SQLite
You can add a new user using our user storage service:
```dart
final storageService = UserStorageService.init();
final user = User("1", "Liam", "Neeson", 18);
await storageService.addUser(user);
```

#### Update a stored User in SQLite
You can update a stored user, in this example first we add a new user and then we are going to update it:
```dart
final storageService = UserStorageService.init();
// User add part
User user = User("1", "Liam", "Neeson", 18);
await storageService.addUser(user);
// Update user part
user.setLastName(finalLastName);
await storageService.updateUser(user);
```

#### Get the list of Users stored in SQLite
You can get the complete list of users stored:
```dart
final storageService = UserStorageService.init();
await storageService.getListOfUsers();
```

#### Get a list of filtered users
We can obtain a list of filtered elements. To do this we create a list of filters that we want to apply:
```dart
final storageService = UserStorageService.init();
List<FilterDb> filters = [
  FilterDb(UserColumnName.lastName.name, "Neeson", ConditionDb.equal),
  FilterDb(UserColumnName.age.name, 18, ConditionDb.greaterOrEqual)
];
final filteredUsers = await storageService.getListOfUsersBy(filters);
```

#### Remove a User stored in SQLite
You can delete a user by passing an instance of it as a parameter:
```dart
final storageService = UserStorageService.init();
final user = User("1", "Liam", "Neeson", 18);
await storageService.removeUser(user);
```

#### Remove ALL Users stored in SQLite
You can delete ALL users:
```dart
final storageService = UserStorageService.init();
await storageService.removeAll();
```

[TableDb]: https://github.com/vicajilau/psqlite/blob/master/lib/src/table_db.dart
[ColumnDb]: https://github.com/vicajilau/psqlite/blob/master/lib/src/column_db.dart
[FieldTypeDb]: https://github.com/vicajilau/psqlite/blob/master/lib/src/field_type_db.dart
[ObjectStored]: https://github.com/vicajilau/psqlite/blob/master/lib/src/object_stored.dart
[PSQLite]: https://github.com/vicajilau/psqlite/blob/master/lib/src/psqlite.dart
[FilterDb]: https://github.com/vicajilau/psqlite/blob/master/lib/src/filter_db.dart
[ConditionDb]: https://github.com/vicajilau/psqlite/blob/master/lib/src/condition_db.dart
