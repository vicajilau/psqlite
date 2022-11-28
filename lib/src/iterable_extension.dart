import 'dart:core';

extension CustomIterable<E> on Iterable<E> {
  /// Count the number of elements that fulfill the function.
  int countWhere(bool Function(E element) test) {
    int number = 0;
    for (E element in this) {
      if (test(element)) {
        number++;
      }
    }
    return number;
  }
}
