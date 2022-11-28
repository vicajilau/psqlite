import 'package:flutter_test/flutter_test.dart';
import 'package:psqlite/psqlite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  test('Mocking TableDb', () async {
    final db = storageService.getDatabase();
    expect(db.getIsMocked(), true);
    db.setMocked(false);
    expect(db.getIsMocked(), false);
  });

  test('Versions of TableDb', () {
    final db = storageService.getDatabase();
    expect(db.getVersion(), 1);
    db.setVersion(2);
    expect(db.getVersion(), 2);
  });

  test('Create TableDb without primary key', () {
    final db = storageService.getDatabase();

    final table = TableDb('users');
    table.addColumn(
        ColumnDb(name: UserColumnName.name.name, type: FieldTypeDb.text));

    db.setTable(table);

    expect(db.getTable(), table);

    expect(() => db.getTable().getCreateDbRequest(), throwsException);
  });

  test('Create TableDb with multiple primary keys', () {
    final db = storageService.getDatabase();

    final table = TableDb('users');
    table.addColumn(ColumnDb(
        name: UserColumnName.name.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true));
    table.addColumn(ColumnDb(
        name: UserColumnName.lastName.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true));

    db.setTable(table);

    expect(db.getTable(), table);

    expect(() => db.getTable().getCreateDbRequest(), throwsException);
  });

  test('Create TableDb with duplicated columns', () {
    final table = TableDb('users');
    final column = ColumnDb(
        name: UserColumnName.name.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true);
    table.addColumn(column);

    expect(() => table.addColumn(column), throwsException);
  });

  test('Create TableDb with empty column name', () {
    final db = storageService.getDatabase();

    final table = TableDb('users');
    table.addColumn(
        ColumnDb(name: "", type: FieldTypeDb.text, isPrimaryKey: true));

    db.setTable(table);

    expect(db.getTable(), table);

    expect(() => db.getTable().getCreateDbRequest(), throwsException);
  });

  test('Replace column', () {
    final table = TableDb('users');
    final column = ColumnDb(
        name: UserColumnName.lastName.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true);
    table.addColumn(column);

    final newColumn =
        ColumnDb(name: 'surname', type: FieldTypeDb.text, isPrimaryKey: true);

    table.replaceColumn(newColumn,
        (column) => column.getName() == UserColumnName.lastName.name);
    final columnFound = table
        .getColumns()
        .firstWhere((column) => column.getName() == 'surname');
    expect(columnFound, newColumn);
  });

  test('Remove column', () {
    final table = TableDb('users');
    final column = ColumnDb(
        name: UserColumnName.lastName.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true);
    table.addColumn(column);

    expect(table.removeColumn(column), true);
    expect(table.removeColumn(column), false);
    expect(table.toString(), 'TableDb{_name: users, _columns: []}');
  });

  test('Search and Remove column', () {
    final table = TableDb('users');
    final columnToRemove = ColumnDb(
        name: UserColumnName.lastName.name,
        type: FieldTypeDb.text,
        isPrimaryKey: true);

    expect(columnToRemove.getType(), FieldTypeDb.text);
    expect(columnToRemove.getName(), UserColumnName.lastName.name);
    expect(columnToRemove.isPrimaryKey(), true);

    table.addColumn(columnToRemove);

    table.searchColumnAndRemoveIt((column) => column == columnToRemove);
    expect(table.toString(), 'TableDb{_name: users, _columns: []}');
  });
}
