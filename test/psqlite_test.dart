import 'package:flutter_test/flutter_test.dart';
import 'package:psqlite/psqlite.dart';
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

  test('Database name', () {
    const oldName = "users";
    const newName = "users2";
    storageService.getDatabase().setDbName(newName);
    expect(storageService.getDatabase().getDbName(), newName);
    storageService.getDatabase().setDbName(oldName);
    expect(storageService.getDatabase().getDbName(), oldName);
  });

  test('initialize constructor', () async {
    final users = await storageService.getListOfUsers();
    expect(users.length, 0);
  });

  test('Add a user', () async {
    final newUser = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(newUser);
    final storedUser = await storageService.getUser("1");
    expect(newUser, storedUser);
  });

  test('Get non stored user', () async {
    final storedUser = await storageService.getUser("2");
    expect(storedUser, null);
  });

  test('Get single stored stored user', () async {
    final newUser = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(newUser);
    final storedUser = await storageService.getUser("1");
    final user = User("1", "Liam", "Neeson", 12);
    expect(storedUser, user);
  });

  test('Update a stored user', () async {
    final newUser = User("1", "Liam", "Neeson", 12);
    const updatedLastName = 'Carreras';
    const finalLastName = 'Neeson';

    await storageService.addUser(newUser);
    User? user = await storageService.getUser("1");

    user?.setLastName(updatedLastName);
    await storageService.updateUser(user!);

    user = await storageService.getUser("1");
    expect(user?.getLastName(), updatedLastName);

    user?.setLastName(finalLastName);
    await storageService.updateUser(user!);
    user = await storageService.getUser("1");
    expect(user?.getLastName(), finalLastName);
  });

  test('Get a list of stored stored user', () async {
    final newUser = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(newUser);
    final storedUser = await storageService.getListOfUsers();
    final user = [User("1", "Liam", "Neeson", 12)];
    expect(storedUser, user);
  });

  test('Remove a user', () async {
    final user = User("1", "Liam", "Neeson", 12);
    await storageService.removeUser(user);
    final storedUser = await storageService.getUser("1");
    expect(storedUser, null);
    final listOfUsers = await storageService.getListOfUsers();
    expect(listOfUsers.length, 0);
  });

  test('Remove a table', () async {
    final user = User("1", "Liam", "Neeson", 12);
    await storageService.addUser(user);
    final storedUser = await storageService.getUser("1");
    expect(storedUser, user);
    await storageService.removeAll();
    final listOfUsers = await storageService.getListOfUsers();
    expect(listOfUsers.length, 0);
  });

  test('Remove users with filters', () async {
    final user1 = User("1", "Liam", "Neeson", 12);
    final user2 = User("2", "Mark", "Neeson", 13);
    final user3= User("3", "John", "Neeson", 14);
    final user4 = User("4", "Amy", "Neeson", 18);
    final user5 = User("5", "Harald", "Neeson", 22);
    await storageService.addUser(user1);
    await storageService.addUser(user2);
    await storageService.addUser(user3);
    await storageService.addUser(user4);
    await storageService.addUser(user5);
    final filters = [FilterDb(UserColumnName.age.name, 18, ConditionDb.less)];
    await storageService.removeUsers(filters);
    final listOfUsers = await storageService.getListOfUsers();
    expect(listOfUsers.length, 2);
  });

  test('Get users with filters', () async {
    final user1 = User("1", "Liam", "Neeson", 12);
    final user2 = User("2", "Mark", "Neeson", 13);
    final user3= User("3", "John", "Neeson", 14);
    final user4 = User("4", "Amy", "Neeson", 18);
    final user5 = User("5", "Harald", "Neeson", 22);

    await storageService.addUser(user1);
    await storageService.addUser(user2);
    await storageService.addUser(user3);
    await storageService.addUser(user4);
    await storageService.addUser(user5);

    List<User> listOfUsers = await storageService.getListOfUsers();
    expect(listOfUsers.length, 5);

    final filters = [FilterDb(UserColumnName.age.name, 18, ConditionDb.greaterOrEqual)];
    listOfUsers =  await storageService.getListOfUsers(where: filters);
    expect(listOfUsers.length, 2);

    final filters2 = [FilterDb(UserColumnName.age.name, 18, ConditionDb.less)];
    listOfUsers =  await storageService.getListOfUsers(where: filters2);
    expect(listOfUsers.length, 3);
  });
}
