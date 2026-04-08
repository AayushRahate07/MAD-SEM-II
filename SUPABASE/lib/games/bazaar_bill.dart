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
                    color: Colors.black.withOpacity(0.9),
                    blurRadius: 10,
                    offset: const Offset(0, 10),
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
                    style: GoogleFonts.courierPrime(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                const Divider(color: Colors.white38, height: 20, thickness: 0.5),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white30, height: 12, thickness: 0.5),
                    itemBuilder: (context, index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(items[index]['name'], style: GoogleFonts.courierPrime(color: Colors.white70, fontSize: 18)),
                        Text("₹${items[index]['price']}", style: GoogleFonts.courierPrime(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
            crossAxisAlignment: CrossAxisAlignment.center, // Aligns label and box vertically
            children: [
              const Text(" TOTAL",
                  style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w500, fontSize: 15)),
              Container(
                width: 90,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TextField(
                  controller: _totalController,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center, // CRITICAL for vertical alignment
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _verifyTotal(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.0, // Force line height to match font size
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,      // Removes ALL internal padding/margins
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
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
    // 1. Map the value (int) to the local asset path (String)
    final Map<int, String> currencyAssets = {
      1: 'assets/currency/1.png',
      2: 'assets/currency/2.png',
      5: 'assets/currency/5.png',
      10: 'assets/currency/10.png',
      20: 'assets/currency/20.png',
      50: 'assets/currency/50.png',
      100: 'assets/currency/100.png',
      200: 'assets/currency/200.png',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2)),
          child: Column(
            children: [
              Text("CASH RECEIVED: ₹$cashGiven", style: GoogleFonts.courierPrime(color: Colors.greenAccent, fontSize: 16)),
              const SizedBox(height: 10),
              Text("₹$changeReturned", style: GoogleFonts.courierPrime(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              Text("RETURN CHANGE", style: GoogleFonts.courierPrime(color: Colors.white24, fontSize: 15)),
              Text("(Total : ₹$totalBill)", style: GoogleFonts.courierPrime(color: Colors.white38, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 20), // Reduced height as images provide visual space
        Expanded(
          child: Wrap(
            spacing: 12, runSpacing: 12,
            alignment: WrapAlignment.center,
            // 2. Iterate through the asset map keys (the values)
            children: currencyAssets.keys.map((n) => InkWell(
              onTap: () => _addChange(n),
              child: Container(
                // 3. Adjusted dimensions to look better with note images
                width: 90, // Slightly wider for notes
                height: 50, // Slightly taller
                decoration: BoxDecoration(
                  // Minimal styling, the image should be the focus
                  color: Colors.transparent,
                  // Useful during debugging to see touch areas
                  // border: Border.all(color: Colors.white10),
                ),
                // 4. Load the specific image using BoxFit.contain
                child: Image.asset(
                  currencyAssets[n]!, // Look up the path based on the value 'n'
                  fit: BoxFit.contain, // Ensures the whole note is visible
                ),
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
                  "NEXT CUSTOMER ARRIVING",
                  textAlign: TextAlign.center,
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
        child: Container(
          // Adjusted padding to match the success tab proportions
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 64),
              const SizedBox(height: 20),
              Text(
                "SESSION OVER",
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w900,
                  fontSize: 26, // Matched to success text size
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // --- STATS CARD (Simplified) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: _statRow("CUSTOMERS SERVED", "$customersServed"),
              ),
              const SizedBox(height: 32),

              // --- EXIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFFF5252), // Brighter red
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFF5252), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "EXIT TO MENU",
                    style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.2
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            label,
            style: GoogleFonts.lexend(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500
            )
        ),
        Text(
            value,
            style: GoogleFonts.lexend(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18
            )
        ),
      ],
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