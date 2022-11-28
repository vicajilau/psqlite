import 'package:psqlite/psqlite.dart';

/// Represents a condition that can be used to filter a request to [PSQLite].
enum ConditionDb {
  /// Represents the symbol (==).
  equal,

  /// Represents the symbol (!=).
  distinct,

  /// Represents the symbol (<).
  less,

  /// Represents the symbol (>).
  greater,

  /// Represents the symbol (<=).
  lessOrEqual,

  /// Represents the symbol (>=).
  greaterOrEqual,

  /// Represents the symbol (LIKE).
  contains,
}

extension CustomConditionDb on ConditionDb {
  /// Generate SQL condition linked.
  String getSqlCondition() {
    switch (this) {
      case ConditionDb.equal:
        return '=';
      case ConditionDb.distinct:
        return '!=';
      case ConditionDb.less:
        return '<';
      case ConditionDb.greater:
        return '>';
      case ConditionDb.lessOrEqual:
        return '<=';
      case ConditionDb.greaterOrEqual:
        return '>=';
      case ConditionDb.contains:
        return 'LIKE';
    }
  }
}
