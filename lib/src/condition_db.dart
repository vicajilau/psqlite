enum ConditionDb {
  equal,
  distinct,
  less,
  greater,
  lessOrEqual,
  greaterOrEqual,
  contains,
}

extension CustomConditionDb on ConditionDb {
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
