import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class BazaarBillGame extends StatefulWidget {
  const BazaarBillGame({super.key});

  @override
  State<BazaarBillGame> createState() => _BazaarBillGameState();
}

class _BazaarBillGameState extends State<BazaarBillGame> {
  // --- GAME STATE ---
  int step = 1;
  int totalBill = 0;
  int cashGiven = 500;
  int changeReturned = 0;
  final TextEditingController _totalController = TextEditingController();
  int customersServed = 0;
  int secondsRemaining = 240;
  Timer? _gameTimer;

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _generateNewCustomer();
    _startTimer();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _totalController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        timer.cancel();
        _showFinalResults();
      }
    });
  }

  void _generateNewCustomer() {
    final random = Random();
    // Randomize item prices
    items = [
      {"name": "MILK PACK", "price": 40 + random.nextInt(40)},
      {"name": "CEREAL", "price": 100 + random.nextInt(50)},
      {"name": "EGGS (DOZ)", "price": 60 + random.nextInt(30)},
      {"name": "BREAD LOAF", "price": 30 + random.nextInt(20)},
    ];
    totalBill = items.fold(0, (sum, item) => sum + (item['price'] as int));

    // Logic for realistic cash given
    cashGiven = ((totalBill / 100).ceil() * 100);
    if (cashGiven == totalBill || random.nextBool()) cashGiven += 100;

    _totalController.clear();
    changeReturned = 0;
    step = 1;
  }

  void _verifyTotal() {
    if (int.tryParse(_totalController.text) == totalBill) {
      setState(() => step = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("INCORRECT TOTAL!"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _addChange(int amount) => setState(() => changeReturned += amount);
  void _resetChange() => setState(() => changeReturned = 0);

  void _submitChange() {
    if (changeReturned == (cashGiven - totalBill)) {
      setState(() => customersServed++);
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WRONG CHANGE!"), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutes = (secondsRemaining ~/ 60).toString();
    String seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF00195A),
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/BAZAARBILL.png',
              fit: BoxFit.cover, // Ensures image fills the screen
            ),
          ),

          // --- DIGITAL TIMER (Overlay) ---
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$minutes:$seconds",
                style: GoogleFonts.shareTechMono(
                  color: secondsRemaining < 30 ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 340,
              height: 500,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white10, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  )
                ],
              ),
              child: step == 1 ? _buildBillingPhase() : _buildChangePhase(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Text("RECEIPT #0892",
                    style: GoogleFonts.courierPrime(color: Colors.white38, fontSize: 15, letterSpacing: 2)),
                const Divider(color: Colors.white12, height: 20, thickness: 0.5),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 12, thickness: 0.5),
                    itemBuilder: (context, index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(items[index]['name'], style: GoogleFonts.courierPrime(color: Colors.white70, fontSize: 14)),
                        Text("₹${items[index]['price']}", style: GoogleFonts.courierPrime(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("  GRAND TOTAL ₹ ", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11)),
              Container(
                width: 90, height: 25,
                color: Colors.white.withOpacity(0.9),
                child: TextField(
                  controller: _totalController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _verifyTotal(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(bottom: 16)),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _btn("CANCEL", const Color(0xFF383838), () => Navigator.pop(context)),
            const SizedBox(width: 10),
            _btn("PROCEED", const Color(0xFF254FBD), _verifyTotal),
          ],
        )
      ],
    );
  }

  Widget _buildChangePhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2)),
          child: Column(
            children: [
              Text("CASH RECEIVED: ₹$cashGiven", style: GoogleFonts.courierPrime(color: Colors.greenAccent, fontSize: 12)),
              const SizedBox(height: 8),
              Text("₹$changeReturned", style: GoogleFonts.courierPrime(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              Text("RETURN CHANGE", style: GoogleFonts.courierPrime(color: Colors.white38, fontSize: 15)),
              Text("(Total : ₹$totalBill)", style: GoogleFonts.courierPrime(color: Colors.white10, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [1, 2, 5, 10, 20, 50, 100, 200, 500].map((n) => InkWell(
              onTap: () => _addChange(n),
              child: Container(
                width: 75, height: 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white10)),
                child: Center(child: Text("₹$n", style: const TextStyle(color: Colors.white70, fontSize: 12))),
              ),
            )).toList(),
          ),
        ),
        Row(
          children: [
            _btn("RESET", Colors.redAccent.withOpacity(0.1), _resetChange, tColor: Colors.redAccent),
            const SizedBox(width: 10),
            _btn("FINISH", Colors.green, _submitChange),
          ],
        )
      ],
    );
  }

  Widget _btn(String txt, Color c, VoidCallback tap, {Color tColor = Colors.white}) {
    return Expanded(
      child: InkWell(
        onTap: tap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
          child: Center(child: Text(txt, style: TextStyle(color: tColor, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Auto-close logic: Wait 2 seconds, then pop and generate new customer
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // Close Dialog
            setState(() => _generateNewCustomer()); // Start next round automatically
          }
        });

        return Dialog(
          backgroundColor: const Color(0xFF303134),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothBlipAnimation(),
                SizedBox(height: 30),
                Text(
                  "CORRECT",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Next customer arriving...",
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF303134),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("TIME'S UP!", style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
              const SizedBox(height: 20),
              _statRow("CUSTOMERS SERVED", "$customersServed"),
              const SizedBox(height: 36),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit Game
                },
                child: Text("EXIT", style: GoogleFonts.lexend(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lexend(color: Colors.white60, fontSize: 12)),
          Text(value, style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

// --- ANIMATION COMPONENTS (Kept from your original logic) ---

class SmoothBlipAnimation extends StatefulWidget {
  const SmoothBlipAnimation({super.key});
  @override
  State<SmoothBlipAnimation> createState() => _SmoothBlipAnimationState();
}

class _SmoothBlipAnimationState extends State<SmoothBlipAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: CustomPaint(
          size: const Size(120, 120),
          painter: SuccessTickPainter(checkPercentage: _checkAnimation.value, accentColor: const Color(0xFF46A358)),
        ),
      ),
    );
  }
}

class SuccessTickPainter extends CustomPainter {
  final double checkPercentage;
  final Color accentColor;
  SuccessTickPainter({required this.checkPercentage, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, Paint()..color = accentColor);
    final paint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.28, size.height * 0.53);
    path.lineTo(size.width * 0.46, size.height * 0.68);
    path.lineTo(size.width * 0.76, size.height * 0.38);
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0.0, metric.length * checkPercentage), paint);
    }
  }
  @override
  bool shouldRepaint(SuccessTickPainter oldDelegate) => oldDelegate.checkPercentage != checkPercentage;
}