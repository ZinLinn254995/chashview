 class FirebasePaths {
  /// Root user node
  static String user(String userId) => 'users/$userId';

  /// Profile path
  static String profile(String userId) => 'users/$userId/profile';

  /// Category base path
  static String categories(String userId) => 'users/$userId/categories';

  /// Category type paths
  static String incomeCategories(String userId) =>
      '${categories(userId)}/income';
  static String expenseCategories(String userId) =>
      '${categories(userId)}/expense';
  static String budgetCategories(String userId) =>
      '${categories(userId)}/budget';
  static String targetCategories(String userId) =>
      '${categories(userId)}/target';

  /// Income, Expense, Budget, Target data paths
  static String income(String userId) => 'users/$userId/income';
  static String expense(String userId) => 'users/$userId/expense';
  static String budget(String userId) => 'users/$userId/budget';
  static String target(String userId) => 'users/$userId/target';
}
