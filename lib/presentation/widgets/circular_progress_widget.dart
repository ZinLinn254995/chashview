import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import 'package:gradient_circular_progress_indicator/gradient_circular_progress_indicator.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Transform.rotate(
      angle: math.pi,
      child: SizedBox(
        width: size,
        height: size,
        child: GradientCircularProgressIndicator(
          progress: p,
          size: size,
          stroke: stroke,
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          backgroundColor: AppColors.backgroundSecondary,
          child: Transform.rotate(
            angle: -math.pi,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(p * 100).toStringAsFixed(0)}%",
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )
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
