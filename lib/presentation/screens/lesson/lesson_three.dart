import 'package:flutter/material.dart';

// သင်ခန်းစာ ၃.၁ မှ ၃.၄ အားလုံးကို ပေါင်းစပ်ထားသော Widget
class LessonThree extends StatelessWidget {
  const LessonThree({super.key});

  @override
  Widget build(BuildContext context) {
    // Parent SingleChildScrollView ကသာ Screen တစ်ခုလုံးကို Scroll လုပ်ပေးပါမည်။
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ------------------------------------------------
          // ၃.၁ Stack နှင့် ၃.၂ Positioned ဥပမာ
          // ------------------------------------------------
          _buildSectionTitle('၃.၁ Stack & ၃.၂ Positioned (Layering)'),

          Container(
            height: 200,
            width: double.infinity,
            color: Colors.pink.shade100,
            child: const Stack( // ၃.၁ Stack
              children: [
                Center(
                  child: Icon(Icons.photo_library, size: 150, color: Colors.pink),
                ),
                Positioned( // ၃.၂ Positioned
                  top: 20, left: 20,
                  child: Text('Layered Text', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink)),
                ),
                Positioned( // ၃.၂ Positioned
                  bottom: 10, right: 10,
                  child: Icon(Icons.favorite, color: Colors.red, size: 40),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------
          // ၃.၃ ListView ဥပမာ
          // ------------------------------------------------
          _buildSectionTitle('၃.၃ ListView (Vertical Scrolling List)'),

          // ListView ကို Column ထဲမှာ ထည့်ရင် အမြင့် ကန့်သတ်ရန် လိုအပ်ပါသည်။
          SizedBox(
            height: 200, // ListView အတွက် အမြင့် သတ်မှတ်
            child: ListView.builder( // ၃.၃ ListView
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.list, color: Colors.pink),
                  title: Text('Scroll Item $index'),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------
          // ၃.၄ GridView ဥပမာ (ပြင်ဆင်ထားသော)
          // ------------------------------------------------
          _buildSectionTitle('၃.၄ GridView (Fixed Height Solution)'),

          // GridView ကို Column ထဲမှာ ထည့်တဲ့အတွက် Scroll ပြဿနာ မဖြစ်အောင် ဖြေရှင်းနည်း ၃ ချက်
          SizedBox(
            // 1. GridView ရဲ့ အမြင့်ကို သတ်မှတ်ခြင်း (ဒီနေရာမှာ စာကြောင်း ၃ ကြောင်းသာရှိသောကြောင့် တွက်ချက်ထားသော အမြင့်)
            height: 350,
            child: GridView.builder( // ၃.၄ GridView
              // 2. GridView ကို သူ့ရဲ့ Content အတိုင်းသာ အမြင့်ကို ယူစေခြင်း
              shrinkWrap: true,

              // 3. GridView ရဲ့ ကိုယ်ပိုင် Scroll စွမ်းရည်ကို ပိတ်လိုက်ခြင်း (Parent ကိုသာ Scroll ခွင့်ပြု)
              physics: const NeverScrollableScrollPhysics(),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0, // Box တွေကို စတုရန်းပုံစံ ထားရန်
              ),
              itemCount: 9, // စုစုပေါင်း Item 9 ခု (3x3)
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.pink.shade200,
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 24)),
                );
              },
            ),
          ),

          const SizedBox(height: 50), // GridView ပြီးသွားရင် အောက်ဘက် နေရာလွတ်
        ],
      ),
    );
  }

  // ခေါင်းစဉ်ပုံစံ ပြုလုပ်ခြင်း
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
      ),
    );
  }
}