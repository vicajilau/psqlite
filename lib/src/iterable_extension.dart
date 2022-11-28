import 'dart:core';

extension CustomIterable<E> on Iterable<E> {
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
