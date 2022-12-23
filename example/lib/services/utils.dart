import 'package:flutter/foundation.dart';

class Utils {
  /// Prints a string representation of the object to the console only in debug mode.
  static void printDebug(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }
}
