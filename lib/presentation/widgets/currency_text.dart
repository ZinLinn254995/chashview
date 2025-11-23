import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_sizes.dart';
import '../../presentation/viewmodels/currency_viewmodel.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool compact; // true => k/M/B format
  final double decimalFontSizeRatio;
  final bool useDecimalRatio; // true => apply decimalFontSizeRatio, false => same as integer

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.compact = false,
    this.decimalFontSizeRatio = 0.7,
    this.useDecimalRatio = false, // default false
  });

  // Remove trailing zeros (e.g. 1.30 -> 1.3, 1.00 -> 1)
  String _trimTrailingZeros(String value) {
    if (value.contains('.')) {
      value = value.replaceAll(RegExp(r'0*$'), '');
      value = value.replaceAll(RegExp(r'\.$'), '');
    }
    return value;
  }

  // return tuple (formattedValue, suffix)
  (String, String) _formatCompact(double value) {
    String suffix = '';
    double result = value;

    if (value >= 1e9) {
      result = value / 1e9;
      suffix = 'B';
    } else if (value >= 1e6) {
      result = value / 1e6;
      suffix = 'M';
    } else if (value >= 1e3) {
      result = value / 1e3;
      suffix = 'k';
    }

    final formatted = _trimTrailingZeros(result.toStringAsFixed(2));
    return (formatted, suffix);
  }

  String _formatFull(double value) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyViewModel>().selectedCurrency;

    String formatted;
    String suffix = '';

    if (compact) {
      final result = _formatCompact(amount);
      formatted = result.$1;
      suffix = result.$2;
    } else {
      formatted = _formatFull(amount);
    }

    // integer / decimal split
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart =
    (parts.length > 1) ? parts[1].replaceAll(RegExp(r'[^0-9]'), '') : '';

    // decimal မ 0 ဖြစ်ရင်သာ ပြမယ်
    final showDecimal =
        decimalPart.isNotEmpty && int.tryParse(decimalPart) != 0;

    final baseStyle = style ??
        const TextStyle(
          fontSize: 20,
          color: Colors.white,
          //fontWeight: AppFontWeight.bold,
        );

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$currency$integerPart',
            style: baseStyle,
          ),
          if (showDecimal)
            TextSpan(
              text: '.$decimalPart',
              style: baseStyle.copyWith(
                fontSize: useDecimalRatio
                    ? baseStyle.fontSize! * decimalFontSizeRatio
                    : baseStyle.fontSize,
                color: baseStyle.color?.withOpacity(0.8),
                //fontWeight: AppFontWeight.bold,
              ),
            ),
          if (suffix.isNotEmpty)
            TextSpan(
              text: suffix,
              style: baseStyle.copyWith(
                fontSize: baseStyle.fontSize! * 0.8,
                color: baseStyle.color?.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }
}
