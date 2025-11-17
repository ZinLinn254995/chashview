import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_currency.dart';

class CurrencyService {
  static const _key = 'selected_currency';

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, currency);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? AppCurrency.baht;
  }
}
