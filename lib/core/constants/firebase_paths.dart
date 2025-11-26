/*
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
*/
class FirebasePaths {
  // User paths
  static String user(String userId) => 'users/$userId';
  static String profile(String userId) => 'users/$userId/profile';

  // Category paths
  static String categories(String userId) => 'users/$userId/categories';
  static String incomeCategories(String userId) => '${categories(userId)}/income';
  static String expenseCategories(String userId) => '${categories(userId)}/expense';

  // Data paths
  static String income(String userId) => 'users/$userId/income';
  static String expense(String userId) => 'users/$userId/expense';

  // Title paths
  static String incomeTitles(String userId) => 'users/$userId/incomeTitles';
  static String expenseTitles(String userId) => 'users/$userId/expenseTitles';

  // Specific item paths
  static String incomeItem(String userId, String itemId) => '${income(userId)}/$itemId';
  static String expenseItem(String userId, String itemId) => '${expense(userId)}/$itemId';
  static String incomeTitle(String userId, String titleId) => '${incomeTitles(userId)}/$titleId';
  static String expenseTitle(String userId, String titleId) => '${expenseTitles(userId)}/$titleId';
  static String category(String userId, String type, String categoryId) =>
      '${categories(userId)}/$type/$categoryId';

  static String budget(String userId) => 'users/$userId/budget';
  static String target(String userId) => 'users/$userId/target';
}