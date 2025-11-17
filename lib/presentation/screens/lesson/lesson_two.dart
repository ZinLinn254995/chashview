import 'package:flutter/material.dart';

// သင်ခန်းစာ ၂.၁ မှ ၂.၄ အားလုံးကို ပေါင်းစပ်ထားသော Widget
class LessonTwo extends StatelessWidget {
  const LessonTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ------------------------------------------------
            // ၂.၁ Main Axis / Cross Axis Alignment ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၂.၁ Main & Cross Axis Alignment'),

            // Row ဥပမာ
            Container(
              height: 120,
              color: Colors.grey.shade200,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // အလျားလိုက် နေရာလွတ်ခွဲဝေ
                crossAxisAlignment: CrossAxisAlignment.center, // ဒေါင်လိုက် အလယ်တည့်တည့်
                children: [
                  _StyledBox(Colors.orange, 50, 50),
                  _StyledBox(Colors.green, 70, 70),
                  _StyledBox(Colors.red, 40, 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Column ဥပမာ
            Container(
              height: 200,
              width: 250,
              color: Colors.grey.shade200,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end, // ဒေါင်လိုက် အောက်ဆုံးကို ပို့
                crossAxisAlignment: CrossAxisAlignment.stretch, // အလျားလိုက် အပြည့်ဆွဲ
                children: [
                  _StyledBox(Colors.purple, 30, 30), // stretch လုပ်ထားလို့ width 250 အပြည့်ဖြစ်မည်
                  _StyledBox(Colors.pink, 30, 30),
                  _StyledBox(Colors.blue, 30, 30),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // ၂.၂ Expanded နှင့် Flexible ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၂.၂ Expanded & Flexible (Space Distribution)'),

            Row(
              children: [
                _StyledBox(Colors.black54, 100, 50), // Fixed Width

                const Expanded( // 👈 Expanded: ကျန်ရှိနေရာလွတ် အားလုံးကိုယူ
                  flex: 2, // flex 2 အချိုးကိုယူမည်
                  child: _StyledBox(Colors.cyan, double.infinity, 50, childText: 'Expanded (2)'),
                ),

                Flexible( // 👈 Flexible: Child လိုသလောက်သာ ယူပြီး ကျန်တာကို ချန်ထား
                  fit: FlexFit.loose, // လိုသလောက်ပဲယူဖို့ သတ်မှတ်
                  child: _StyledBox(Colors.brown, double.infinity, 50, childText: 'Flexible'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // ၂.၃ Spacer ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၂.၃ Spacer (Quick Spacing)'),

            Row(
              children: [
                _StyledButton('Start', Colors.orange),
                const Spacer(flex: 3), // 👈 Spacer: နေရာလွတ်ကို flex 3 ဖြင့် ယူ
                _StyledButton('Middle', Colors.red),
                const Spacer(flex: 1), // 👈 Spacer: နေရာလွတ်ကို flex 1 ဖြင့် ယူ (Middle နဲ့ End ကြား နည်းမည်)
                _StyledButton('End', Colors.purple),
              ],
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // ၂.၄ Center နှင့် Align ဥပမာ
            // ------------------------------------------------
            _buildSectionTitle('၂.၄ Center & Align (Specific Positioning)'),

            Container(
              height: 150,
              width: double.infinity,
              color: Colors.lightGreen.shade100,
              child: Stack( // Align ကို Container (သို့မဟုတ်) Stack ထဲမှာ သုံးနိုင်သည်
                children: const [
                  Center( // 👈 Center: Parent ရဲ့ အလယ်တည့်တည့်
                    child: Text('This Text is Centered', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Align( // 👈 Align: Parent ရဲ့ သတ်မှတ်ထားသော နေရာ
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.check_circle, color: Colors.green),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }
}

// ----------------------------------------------------
// Custom Reusable Widgets
// ----------------------------------------------------

// အရောင်နဲ့ အရွယ်အစား သတ်မှတ်ထားသော Box (Container)
class _StyledBox extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final String? childText;

  const _StyledBox(this.color, this.width, this.height, {this.childText = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: childText != ''
          ? Text(
        childText!,
        style: const TextStyle(color: Colors.white, fontSize: 10),
        textAlign: TextAlign.center,
      )
          : null,
    );
  }
}

// ခလုတ်ပုံစံ
class _StyledButton extends StatelessWidget {
  final String text;
  final Color color;

  const _StyledButton(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}