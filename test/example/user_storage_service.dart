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
