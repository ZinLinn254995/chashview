import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  // Normal state colors
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  // Pressed state colors
  final Color pressedBackgroundColor;
  final Color pressedForegroundColor;
  final Color pressedBorderColor;

  const AppButton({
    super.key,
    required this.onPressed,
    this.text = '+ Add',
    this.backgroundColor = AppColors.neonLime,
    this.foregroundColor = AppColors.textBlack,
    this.borderColor = AppColors.borderTransparent,
    this.pressedBackgroundColor = AppColors.black,
    this.pressedForegroundColor = AppColors.white,
    this.pressedBorderColor = AppColors.borderNeonLime,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTap() async {
    setState(() => _isPressed = true);
    widget.onPressed();
    await Future.delayed(const Duration(milliseconds: 180)); // ✅ pressed state visible 1s
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isPressed
        ? widget.pressedBackgroundColor
        : widget.backgroundColor;
    final Color fgColor = _isPressed
        ? widget.pressedForegroundColor
        : widget.foregroundColor;
    final Color borderColor = _isPressed
        ? widget.pressedBorderColor
        : widget.borderColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // smooth fade
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
              child: Text(widget.text),
            ),
          ),
        ),
      ),
    );
  }
}
