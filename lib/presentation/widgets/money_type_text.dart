import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';


class MoneyTypeText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  const MoneyTypeText(
      this.text, {
        super.key,
        this.color = AppColors.textWhite,
        this.fontSize = AppFontSize.xs,
        this.fontWeight = FontWeight.normal,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
