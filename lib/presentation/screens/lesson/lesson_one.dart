// lib/presentation/screens/lesson/lesson_one.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class LessonOne extends StatelessWidget {
  const LessonOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(AppPadding.md),
              child: Text(
                '၁.၁ Container နှင့် ၁.၅ Padding ဥပမာ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'ဤ Container သည် အနားကွေး၊ အတွင်းနှင့် အပြင် နေရာလွတ်များဖြင့် စတိုင်လ်ပြုထားပါသည်။',
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 10.0),
              child: Text(
                '၁.၂ Row နှင့် ၁.၄ SizedBox ဥပမာ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _StyledBox(Colors.green.shade600, 80, 80),
                const SizedBox(width: 15),
                _StyledBox(Colors.yellow.shade700, 80, 80),
                const SizedBox(width: 15),
                _StyledBox(Colors.red.shade600, 80, 80),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StyledBox extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _StyledBox(this.color, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
