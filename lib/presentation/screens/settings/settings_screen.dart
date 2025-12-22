import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_currency.dart';
// import '../../viewmodels/auth_viewmodel.dart'; // မလိုတော့တဲ့ viewmodel တွေ ဖျက်နိုင်ပါတယ်
import '../../../core/routing/route_names.dart';
import '../../viewmodels/currency_viewmodel.dart';
// import '../../viewmodels/main_viewmodel.dart'; // 🔥 ဖယ်ရှားပါ
import '../../widgets/circular_progress_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double progressValue = 0.5; // 50%

  @override
  Widget build(BuildContext context) {
    final currencyViewModel = context.watch<CurrencyViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressWidget(progress: progressValue, size: 180),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    progressValue += 0.1;
                    if (progressValue > 1.0) progressValue = 0.0;
                  });
                },
                child: const Text('Increase Progress'),
              ),
              const SizedBox(height: 20),

              // 🔥 Lesson Buttons များကို Navigator.pushNamed ဖြင့် အစားထိုးခြင်း
              ElevatedButton(
                onPressed: () {
                  // BottomNav ကို ဖျောက်ပြီး route အသစ်ကို push ပါ
                  Navigator.pushNamed(context, RouteNames.lessonOne);
                },
                child: const Text('Lesson 1'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.lessonTwo);
                },
                child: const Text('Lesson 2'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.lessonThree);
                },
                child: const Text('Lesson 3'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.lessonFour);
                },
                child: const Text('Lesson 4'),
              ),

              ElevatedButton(
                onPressed: () {
                  // Category List ကို သွားရန်
                  Navigator.pushNamed(context, RouteNames.category);
                },
                child: const Text('Go to Category List'),
              ),


              const SizedBox(height: 30),

              // ✅ Currency Dropdown Added Below
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: currencyViewModel.selectedCurrency,
                  isExpanded: true,
                  dropdownColor: Colors.grey[900],
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: AppCurrency.currencyList.map((symbol) {
                    final displayText =
                        "${AppCurrency.currencyFullName[symbol]} ($symbol)";
                    return DropdownMenuItem<String>(
                      value: symbol,
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      currencyViewModel.changeCurrency(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Current: ${currencyViewModel.selectedCurrency}",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}