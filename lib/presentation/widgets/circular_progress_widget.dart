import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import 'package:gradient_circular_progress_indicator/gradient_circular_progress_indicator.dart';

import '../../core/constants/app_sizes.dart';

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double stroke;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 100.0,
    this.stroke = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Transform.rotate(
      // ⬅️ အောက်ကနေစဖို့ 180° (pi radians) လှည့်
      angle: math.pi,
      child: SizedBox(
        width: size,
        height: size,
        child: GradientCircularProgressIndicator(
          progress: p,
          size: size,
          stroke: stroke,
          gradient: const LinearGradient(
            colors: [
              AppColors.hotPink,
              AppColors.neonLime,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          backgroundColor: AppColors.backgroundSecondary,
          child: Transform.rotate(
            // ⬅️ Label ကို ပြန်အနေအထားမှန်အောင် ပြန်ပြင်
            angle: -math.pi,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(p * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppFontSize.md,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Progress",
                    style: TextStyle(
                      color: AppColors.textHotPink,
                      fontSize: AppFontSize.xxs,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
