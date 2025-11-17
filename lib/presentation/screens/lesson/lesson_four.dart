import 'package:flutter/material.dart';

// သင်ခန်းစာ ၄.၁ မှ ၄.၂ အားလုံးကို ပေါင်းစပ်ထားသော Widget
class LessonFour extends StatelessWidget {
  const LessonFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ------------------------------------------------
            // ၄.၁ Wrap Widget ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၄.၁ Wrap Widget (Auto Line Break)'),

            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrange, width: 2),
              ),
              child: Wrap(
                // 👈 ၄.၁ Wrap: Widgets တွေ အလျားမဆံ့ရင် အောက်ကို ဆင်းသွားမည်
                spacing: 8.0, // အလျားလိုက် နေရာလွတ်
                runSpacing: 8.0, // ဒေါင်လိုက် (အတန်းများကြား) နေရာလွတ်
                children: [
                  _Chip('Flutter'),
                  _Chip('Dart'),
                  _Chip('Layout'),
                  _Chip('Widgets'),
                  _Chip('Container'),
                  _Chip('Row'),
                  _Chip('Column'),
                  _Chip('Advanced'), // ဒါက အောက်ကြောင်းကို ဆင်းသွားနိုင်သည်
                  _Chip('Wrap'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // ၄.၂ Nesting Layout Widgets ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၄.၂ Nesting Layout (Row, Column, Expanded)'),

            // Outer Column
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                // Outer Row
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side (Fixed Image)
                  Icon(Icons.person_pin, size: 60, color: Colors.deepOrange),
                  SizedBox(width: 10),

                  // Right Side (Expanded Column)
                  Expanded(
                    // ကျန်ရှိနေရာလွတ် အကုန်ယူ
                    child: Column(
                      // Inner Column
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Profile Card',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'This section uses a Row (Icon + Column) and a Column (Title + Subtitle) inside the Row, with Expanded for flexible sizing.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 8),

                        // Nested Row inside the Column
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            SizedBox(width: 5),
                            Text('4.9 Rating', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ခေါင်းစဉ်ပုံစံ ပြုလုပ်ခြင်း
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Custom Reusable Widget (၄.၁ Wrap အတွက်)
// ----------------------------------------------------
class _Chip extends StatelessWidget {
  final String text;

  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.deepOrange.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
