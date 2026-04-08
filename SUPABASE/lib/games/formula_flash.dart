import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class FormulaFlashGame extends StatefulWidget {
  const FormulaFlashGame({super.key});

  @override
  State<FormulaFlashGame> createState() => _FormulaFlashGameState();
}

class _FormulaFlashGameState extends State<FormulaFlashGame> {
  final List<String> _data = [
    'Square Area', 's²',
    'Circle Area', 'πr²',
    'Cube Volume', 's³',
    'Rectangle Area', 'l × w',
    'Sphere SA', '4πr²',
    'Cuboid Volume', 'l × w × h',
  ];

  List<String> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstIndex;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _cards = List.from(_data)..shuffle();
      _flipped = List.generate(_cards.length, (_) => false);
      _matched = List.generate(_cards.length, (_) => false);
      _firstIndex = null;
      _isBusy = false;
    });
  }

  void _onTap(int index) {
    if (_isBusy || _flipped[index] || _matched[index]) return;
    setState(() => _flipped[index] = true);
    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _checkMatch(_firstIndex!, index);
    }
  }

  void _checkMatch(int i1, int i2) {
    _isBusy = true;
    bool isMatch = (_data.indexOf(_cards[i1]) ~/ 2) == (_data.indexOf(_cards[i2]) ~/ 2);

    Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          if (isMatch) {
            _matched[i1] = _matched[i2] = true;
            if (_matched.every((m) => m == true)) _showWinDialog();
          } else {
            _flipped[i1] = _flipped[i2] = false;
          }
          _firstIndex = null;
          _isBusy = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00195A), Color(0xFF000C2D)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600), // Limits width on tablets/web
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shrinkWrap: true, // Key: Keeps the grid tight to its content
                    physics: const ClampingScrollPhysics(), // Disables the "bouncing" effect
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, i) => _buildCard(i),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 90, top: 0),
              child: Center( // This ensures the button only takes up the space it needs
                child: _actionButton(
                    "RESET BOARD",
                    Colors.white.withOpacity(0.1),
                    _resetGame
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int i) {
    bool isVisible = _flipped[i] || _matched[i];

    return GestureDetector(
      onTap: () => _onTap(i),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isVisible ? pi : 0),
        // Increased duration slightly for a smoother "weighty" feel
        duration: const Duration(milliseconds: 500),
        // Added a curve that adds a tiny bounce at the end
        curve: Curves.easeInOutBack,
        builder: (context, rotationValue, __) {
          bool isBack = rotationValue >= (pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // Slightly increased depth perception
              ..rotateY(rotationValue),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
                image: !isBack
                    ? const DecorationImage(
                  image: AssetImage('assets/card.png'),
                  fit: BoxFit.cover,
                )
                    : null,
                color: isBack
                    ? (_matched[i] ? const Color(0xFF46A358) : Colors.white)
                    : const Color(0xFF1A237E),
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  // Reverse the mirroring of the text
                  transform: Matrix4.identity()..rotateY(isBack ? pi : 0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      isBack ? _cards[i] : "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        // Fade the text in only when the card is fully flipped
                        color: isBack ? Colors.black87 : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        // Padding handles the internal spacing automatically
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13, // Slightly increased for readability
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF000C2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SmoothBlipAnimation(),
              const SizedBox(height: 25),
              const Text(
                "EXCELLENT!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "YOU'VE MASTERED FORMULAS!",
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 30),
              // --- ROW FOR TWO BUTTONS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. EXIT BUTTON
                  _actionButton(
                    "EXIT",
                    Colors.redAccent.withOpacity(0.1),
                        () {
                      Navigator.pop(context); // Close Dialog
                      Navigator.pop(context); // Exit Game Screen
                    },
                  ),
                  const SizedBox(width: 12),
                  // 2. PLAY AGAIN BUTTON
                  _actionButton(
                    "PLAY AGAIN",
                    const Color(0xFF254FBD),
                        () {
                      Navigator.pop(context); // Close Dialog
                      _resetGame();          // Restart Game
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ANIMATION CLASSES (PASTE OUTSIDE THE MAIN CLASS) ---

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
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: CustomPaint(
          size: const Size(120, 120),
          painter: FormulaFlashPainter(checkPercentage: _checkAnimation.value, accentColor: const Color(0xFF254FBD)),
        ),
      ),
    );
  }
}

class FormulaFlashPainter extends CustomPainter {
  final double checkPercentage;
  final Color accentColor;
  FormulaFlashPainter({required this.checkPercentage, required this.accentColor});

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
  bool shouldRepaint(FormulaFlashPainter oldDelegate) => oldDelegate.checkPercentage != checkPercentage;
}