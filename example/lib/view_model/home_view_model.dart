import '../model/user.dart';
import '../services/user_storage_service.dart';

class HomeViewModel {
  List<User> _userCollection = [];

  int numberOfFiles() => _userCollection.length;
  List<User> getUsers() => _userCollection;
  final database = UserStorageService.shared;

  Future<void> loadUsers() async {
    _userCollection = await database.getListOfUsers();
  }

  /// This method is used when you want to remove a user from DB
  Future<void> removeUser(User user) async {
    await database.removeUser(user);
    _userCollection.remove(user);
  }

  /// This method is used only to move cells
  User removeUserAt(int index) => _userCollection.removeAt(index);
  void insertUserAt(int index, User user) =>
      _userCollection.insert(index, user);
  Future<void> addUser(User user) async {
    await database.addUser(user);
    _userCollection.add(user);
  }
}
