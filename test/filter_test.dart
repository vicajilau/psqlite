import 'package:flutter_test/flutter_test.dart';
import 'package:psqlite/src/filter_db.dart';
import 'package:psqlite/src/condition_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../example/lib/model/user.dart';
import '../example/lib/services/user_storage_service.dart';

Future main() async {
  late UserStorageService storageService;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
    storageService = UserStorageService.init(mockedDatabase: true);
  });

  setUp(() async {
    await storageService.removeAll();
  });

  test('initialize constructor', () async {
    final users = await storageService.getListOfUsers();
    expect(users.length, 0);
  });

  test('Filtering lastnames', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.lastName.name, "Neeson", ConditionDb.equal)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user1, user2];
    expect(storedUser, filteredUsers);
  });

  test('Filtering lastnames of legal age', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.lastName.name, "Neeson", ConditionDb.equal),
      FilterDb(UserColumnName.age.name, 18, ConditionDb.greaterOrEqual)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user2];
    expect(storedUser, filteredUsers);
  });

  test('Filtering less condition', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 18, ConditionDb.less)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user1];
    expect(storedUser, filteredUsers);
  });

  test('Filtering greater condition', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 18, ConditionDb.greater)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user3];
    expect(storedUser, filteredUsers);
  });

  test('Filtering greater or equal', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 18, ConditionDb.greaterOrEqual)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user2, user3];
    expect(storedUser, filteredUsers);
  });

  test('Filtering less or equal', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 18, ConditionDb.lessOrEqual)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user1, user2];
    expect(storedUser, filteredUsers);
  });

  test('Filtering with empty results', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 22, ConditionDb.greaterOrEqual)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [];
    expect(storedUser, filteredUsers);
  });

  test('Filtering distinct', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.age.name, 18, ConditionDb.distinct)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user1, user3];
    expect(storedUser, filteredUsers);
  });

  test('Filtering a wrong column', () async {
    List<FilterDb> filters = [FilterDb('wrongName', 14, ConditionDb.equal)];

    expect(storageService.getListOfUsersBy(filters),
        throwsA(isInstanceOf<Exception>()));
  });

  test('Filtering contains', () async {
    List<FilterDb> filters = [
      FilterDb(UserColumnName.lastName.name, 'Nee', ConditionDb.contains)
    ];

    final user1 = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user1);
    final user2 = User("2", "Luke", "Neeson", 18);
    await storageService.addUser(user2);
    final user3 = User("3", "John", "Smith", 21);
    await storageService.addUser(user3);

    final storedUser = await storageService.getListOfUsersBy(filters);
    final filteredUsers = [user1, user2];
    expect(storedUser, filteredUsers);
  });
}
