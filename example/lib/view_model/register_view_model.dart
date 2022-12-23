import '../model/user.dart';

class RegisterViewModel {
  Future<User> registerUser(
      String userID, String name, String lastName, int age) async {
    return User(userID, name, lastName, age);
  }
}
