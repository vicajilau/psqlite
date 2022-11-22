# psqlite

[![pub package](https://img.shields.io/pub/v/sqflite.svg)](https://pub.dev/packages/psqlite)

Easily manipulate sqlite databases in Dart using this package.

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
```

### Create a User Storage Service 

The easiest way to encapsulate the data persistence of the User object that we have created is by creating a wrapper service.
Inside we will create the columns of the table and the name of the database.
The mockedDatabase parameter will allow us to perform unit tests on our service.

```dart
import 'package:psqlite/psqlite.dart';

import 'user.dart';

class UserStorageService {
  static final shared = UserStorageService.init();
  late PSQLite _database;

  UserStorageService.init({bool mockedDatabase = false}) {
    List<ColumnDb> columns = [
      ColumnDb(
              fieldName: 'id', fieldType: FieldTypeDb.text, isPrimaryKey: true),
      ColumnDb(fieldName: 'name', fieldType: FieldTypeDb.text),
      ColumnDb(fieldName: 'lastName', fieldType: FieldTypeDb.text)
    ];
    final table = TableDb.create(name: 'users', columns: columns);
    _database = PSQLite(table: table, isMocked: mockedDatabase);
  }

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
      return User(response['id'], response['name'], response['lastName']);
    }
    return null;
  }

  Future<List<User>> getListOfUsers() async {
    final maps = await _database.getElements();
    return List.generate(maps.length, (i) {
      return User(maps[i]['id'], maps[i]['name'], maps[i]['lastName']);
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
final user = User("1", "Liam", "Neeson");
await storageService.addUser(user);
```

#### Update a stored User in SQLite
You can update a stored user, in this example first we add a new user and then we are going to update it:
```dart
final storageService = UserStorageService.init();
// User add part
User user = User("1", "Liam", "Neeson");
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

#### Remove a User stored in SQLite
You can delete a user by passing an instance of it as a parameter:
```dart
final storageService = UserStorageService.init();
final user = User("1", "Liam", "Neeson");
await storageService.removeUser(user);
```

#### Remove ALL Users stored in SQLite
You can delete ALL users:
```dart
final storageService = UserStorageService.init();
await storageService.removeAll();
```