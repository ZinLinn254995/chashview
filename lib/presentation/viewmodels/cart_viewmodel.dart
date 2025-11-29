// cart_viewmodel.dart - simple version
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../../../domain/entities/title_entity.dart';

class CartViewModel extends ChangeNotifier {
  final List<TitleEntity> _cartItems = [];

  List<TitleEntity> get cartItems => _cartItems;

  bool isInCart(String titleId) {
    return _cartItems.any((item) => item.id == titleId);
  }

  void addToCart(TitleEntity title) {
    if (!isInCart(title.id)) {
      _cartItems.add(title);
      notifyListeners();
    }
  }

  void removeFromCart(String titleId) {
    _cartItems.removeWhere((item) => item.id == titleId);
    notifyListeners();
  }

  // 🔥 Fix: Only one parameter needed
  void toggleCart(TitleEntity title) {
    if (isInCart(title.id)) {
      removeFromCart(title.id);
    } else {
      addToCart(title);
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  List<TitleEntity> getTitlesByCategory(String categoryId) {
    return _cartItems.where((title) => title.categoryId == categoryId).toList();
  }

  Map<String, List<TitleEntity>> getGroupedCartItems() {
    final grouped = groupBy(_cartItems, (title) => title.categoryId);
    return grouped;
  }
}