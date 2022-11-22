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
