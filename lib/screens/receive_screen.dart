import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'finished_screen.dart';

class ReceiveScreen extends StatefulWidget {
  final List<int> redPackets;

  const ReceiveScreen({super.key, required this.redPackets});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _MoneyParticle {
  double left;
  double top;
  final double size;

  _MoneyParticle({
    required this.left,
    required this.top,
    required this.size,
  });
}

class _ReceiveScreenState extends State<ReceiveScreen>
    with TickerProviderStateMixin {
  late List<int> remainingPackets;
  List<int> receivedPackets = [];
  int? lastReceived;

  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _cooldownController;

  final Random random = Random();

  bool _canTap = true;
  List<_MoneyParticle> particles = [];

  @override
  void initState() {
    super.initState();

    remainingPackets = List.from(widget.redPackets);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _cooldownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _cooldownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _canTap = true;
        });
        _cooldownController.reset();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    _cooldownController.dispose();
    super.dispose();
  }

  void spawnMoneyParticles() {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;

    for (int i = 0; i < 8; i++) {
      particles.add(
        _MoneyParticle(
          left: centerX - 15,
          top: 420,
          size: 24 + random.nextDouble() * 18,
        ),
      );
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        for (var p in particles) {
          p.top -= 150 + random.nextDouble() * 200;
          p.left += random.nextDouble() * 200 - 100;
        }
      });
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        particles.clear();
      });
    });
  }

  void receiveRedPacket() {
    if (!_canTap) return;
    if (remainingPackets.isEmpty) return;

    setState(() {
      _canTap = false;
    });

    _cooldownController.forward(from: 0);

    int index = random.nextInt(remainingPackets.length);
    int value = remainingPackets[index];

    setState(() {
      lastReceived = value;
      receivedPackets.insert(0, value);
      remainingPackets.removeAt(index);
    });

    _shakeController.forward(from: 0);
    _confettiController.play();
    spawnMoneyParticles();

    if (remainingPackets.isEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FinishedScreen(
              totalMoney: receivedPackets.fold(0, (a, b) => a + b),
              totalCount: receivedPackets.length,
            ),
          ),
        );
      });
    }
  }

  String formatMoney(int money) {
    return "${money ~/ 1000}k";
  }

  @override
  Widget build(BuildContext context) {
    final total = receivedPackets.length + remainingPackets.length;
    final progress = total == 0 ? 0.0 : receivedPackets.length / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("🧧 Phát Lì Xì"),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: lastReceived == null
                      ? const SizedBox(height: 60)
                      : Container(
                          key: ValueKey(lastReceived),
                          padding: const EdgeInsets.all(32),
                          margin: const EdgeInsets.symmetric(horizontal: 64),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6)
                            ],
                          ),
                          child: Text(
                            "🎉 ${formatMoney(lastReceived!)} 🎉",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: receiveRedPacket,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              width: 250,
                              child: AnimatedBuilder(
                                animation: _cooldownController,
                                builder: (context, _) {
                                  return CircularProgressIndicator(
                                    value: _canTap
                                        ? 0
                                        : 1 - _cooldownController.value,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: const AlwaysStoppedAnimation(
                                        Colors.red),
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 220,
                              width: 160,
                              decoration: BoxDecoration(
                                color: remainingPackets.isEmpty
                                    ? Colors.grey
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  "🧧",
                                  style: TextStyle(fontSize: 110),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Đã phát ${receivedPackets.length} / $total bao lì xì",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          ...particles.map((p) => AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                left: p.left,
                top: p.top,
                child: Text(
                  "💵",
                  style: TextStyle(fontSize: p.size),
                ),
              )),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              gravity: 0.3,
              colors: const [
                Colors.red,
                Colors.amber,
                Colors.orange,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
