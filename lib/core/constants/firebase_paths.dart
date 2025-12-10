// lib/core/constants/firebase_paths.dart
class FirebasePaths {
  // 🔥 NEW: Root users collection path
  static String users() => 'users';

  // Existing User paths
  static String user(String userId) => 'users/$userId';
  static String profile(String userId) => 'users/$userId/profile';

  // 🔥 NEW: Plan paths
  static String plans() => 'plans';
  static String plan(String planId) => 'plans/$planId';

  // 🔥 NEW: Top-up paths
  static String topUps() => 'topUps';
  static String topUp(String code) => 'topUps/$code';

  // 🔥 NEW: Transaction paths
  static String transactions() => 'transactions';
  static String transaction(String transactionId) => 'transactions/$transactionId';

  // Category paths
  static String categories(String userId) => 'users/$userId/categories';
  static String categoriesByType(String userId, String type) => '${categories(userId)}/$type';
  // static String incomeCategories(String userId) => categoriesByType(userId, 'income');
  // static String expenseCategories(String userId) => categoriesByType(userId, 'expense');
  // static String incomeCategories(String userId) => '${categories(userId)}/income';
  // static String expenseCategories(String userId) => '${categories(userId)}/expense';


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