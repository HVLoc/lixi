import 'package:flutter/material.dart';
import 'receive_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final Map<int, TextEditingController> controllers = {
    500000: TextEditingController(),
    200000: TextEditingController(),
    100000: TextEditingController(),
    50000: TextEditingController(),
    20000: TextEditingController(),
    10000: TextEditingController(),
  };

  int totalMoney = 0;
  int totalCount = 0;

  void _calculateTotal() {
    int money = 0;
    int count = 0;

    controllers.forEach((value, controller) {
      int quantity = int.tryParse(controller.text) ?? 0;
      count += quantity;
      money += quantity * value;
    });

    setState(() {
      totalMoney = money;
      totalCount = count;
    });
  }

  void startGame() {
    if (totalCount == 0) return;

    List<int> redPackets = [];

    controllers.forEach((value, controller) {
      int quantity = int.tryParse(controller.text) ?? 0;
      for (int i = 0; i < quantity; i++) {
        redPackets.add(value);
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiveScreen(redPackets: redPackets),
      ),
    );
  }

  String formatMoney(int money) {
    if (money == 0) return "0";
    return "${money ~/ 1000}k";
  }

  Widget buildInputRow(int value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            "${value ~/ 1000}k",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controllers[value],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => _calculateTotal(), // 🔥 REALTIME
              decoration: const InputDecoration(
                hintText: "0",
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("🧧 LÌ XÌ TẾT $year 🧧",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            )),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 💰 Tổng tiền realtime
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Tổng lì xì",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatMoney(totalMoney),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalCount bao",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: controllers.keys
                    .map((value) => buildInputRow(value))
                    .toList(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: totalCount == 0 ? null : startGame,
                child: const Text(
                  "BẮT ĐẦU PHÁT LÌ XÌ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
