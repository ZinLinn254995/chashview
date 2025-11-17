import 'package:flutter/material.dart';
import '../../core/constants/app_currency.dart';
import '../../core/services/currency_service.dart';

class CurrencyViewModel extends ChangeNotifier {
  final CurrencyService _service;

  CurrencyViewModel({CurrencyService? service})
      : _service = service ?? CurrencyService() {
    loadCurrency();
  }

  String _selectedCurrency = AppCurrency.baht;
  String get selectedCurrency => _selectedCurrency;

  Future<void> loadCurrency() async {
    final saved = await _service.getCurrency();
    // ✅ check if saved value is valid
    if (AppCurrency.currencyList.contains(saved)) {
      _selectedCurrency = saved;
    } else {
      _selectedCurrency = AppCurrency.baht;
      await _service.setCurrency(AppCurrency.baht);
    }
    notifyListeners();
  }


  Future<void> changeCurrency(String newCurrency) async {
    _selectedCurrency = newCurrency;
    await _service.setCurrency(newCurrency);
    notifyListeners();
  }
}
