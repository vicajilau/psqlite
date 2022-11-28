import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'example/user.dart';
import 'example/user_storage_service.dart';

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
}
