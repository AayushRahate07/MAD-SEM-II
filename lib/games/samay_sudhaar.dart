import 'package:flutter/material.dart';
import 'dart:math';

class SamaySudhaarGame extends StatefulWidget {
  const SamaySudhaarGame({super.key});

  @override
  State<SamaySudhaarGame> createState() => _SamaySudhaarGameState();
}

class _SamaySudhaarGameState extends State<SamaySudhaarGame> {
  int hour = 12;
  int minute = 0;
  final Random _random = Random();
  
  // --- GAME STATE VARIABLES ---
  int score = 0;
  int currentQuestionIndex = 0;
  final int maxQuestions = 6;
  List<Map<String, dynamic>> sessionRiddles = [];
  Map<String, dynamic>? currentRiddle;

  // --- THE 10-QUESTION BANK ---
  final List<Map<String, dynamic>> allRiddles = [
    {
      "riddle": "When both hands point straight up, but the sun is shining brightly, what time is it?",
      "h": 12, "m": 0,
      "fact": "At 12:00 PM on August 15, 1947, India had officially begun its first full day of independence!"
    },
    {
      "riddle": "It is exactly 15 minutes before the clock strikes 3.",
      "h": 2, "m": 45,
      "fact": "Did you know? The concept of the number zero was invented in India by Aryabhata."
    },
    { 
      "riddle": "The hour hand is exactly halfway between 4 and 5, and the minute hand points straight down.", 
      "h": 4, "m": 30, 
      "fact": "Around 4:30 PM, millions of Indian households take a break for their evening 'Chai' (tea)!" 
    },
    { 
      "riddle": "The small hand points to 9, and the big hand points straight up to 12.", 
      "h": 9, "m": 0, 
      "fact": "At 9:00 AM on January 26, 1950, preparations were in full swing for India's first Republic Day parade." 
    },
    {
      "riddle": "It is exactly ten minutes past ten.",
      "h": 10, "m": 10,
      "fact": "Look closely at clocks in advertisements! They are almost always set to 10:10 because it looks like a happy smile."
    },
    {
      "riddle": "The minute hand is at 6, and the hour hand is exactly between 7 and 8.",
      "h": 7, "m": 30,
      "fact": "7:30 PM is often considered 'Prime Time' for family television viewing across India."
    },
    {
      "riddle": "Set the clock to a quarter past 6.",
      "h": 6, "m": 15,
      "fact": "Sunrise in many parts of India happens around 6:15 AM during the spring season."
    },
    {
      "riddle": "There are exactly 20 minutes left before it turns 6 o'clock.",
      "h": 5, "m": 40,
      "fact": "The Indian Railways is the fourth largest railway network in the world, running over 13,000 passenger trains daily!"
    },
    {
      "riddle": "Both hands are resting exactly on the number 3. Wait, that means...",
      "h": 3, "m": 15,
      "fact": "While the hands look completely overlapped, at 3:15 the hour hand has actually moved slightly past the 3!"
    },
    {
      "riddle": "Set the time to exactly half past eight.",
      "h": 8, "m": 30,
      "fact": "At 8:30 AM, millions of students across India are settling into their first period of school."
    }
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      // 1. Shuffle the main bank
      List<Map<String, dynamic>> shuffledBank = List.from(allRiddles)..shuffle(_random);
      // 2. Take exactly 6 random questions for this session
      sessionRiddles = shuffledBank.take(maxQuestions).toList();
      
      // 3. Reset stats
      score = 0;
      currentQuestionIndex = 0;
      _loadCurrentRiddle();
    });
  }

  void _loadCurrentRiddle() {
    setState(() {
      currentRiddle = sessionRiddles[currentQuestionIndex];
      hour = 12;
      minute = 0;
    });
  }

  void _changeTime({int h = 0, int m = 0}) {
    setState(() {
      hour = (hour + h + 12) % 12;
      if (hour == 0) hour = 12;
      minute = (minute + m + 60) % 60;
    });
  }

  void _checkAnswer() {
    bool correct = (hour == currentRiddle!["h"] && minute == currentRiddle!["m"]);
    
    if (correct) {
      score += 10;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          correct ? '✅ Perfect! +10' : '❌ Oops!', 
          style: TextStyle(color: correct ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold)
        ),
        content: Text(correct 
            ? currentRiddle!["fact"] 
            : "The correct time was ${currentRiddle!["h"]}:${currentRiddle!["m"].toString().padLeft(2, '0')}!\n\n${currentRiddle!["fact"]}"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _nextQuestionOrEnd(); // Move to the next phase
            },
            child: Text(currentQuestionIndex < maxQuestions - 1 ? 'Next Question' : 'See Results'),
          )
        ],
      ),
    );
  }

  void _nextQuestionOrEnd() {
    currentQuestionIndex++;
    
    if (currentQuestionIndex < maxQuestions) {
      // Load the next question in our 6-question list
      _loadCurrentRiddle();
    } else {
      // Game Over Screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Game Over!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Your Final Score:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("$score / ${maxQuestions * 10}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                _startGame(); // Restart a completely fresh session
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to main menu
              },
              child: const Text('Main Menu', style: TextStyle(color: Colors.indigo)),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentRiddle == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Q: ${currentQuestionIndex + 1}/$maxQuestions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('⭐ Score: $score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Riddle Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Text(
                    currentRiddle!["riddle"],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Analog Clock Visualization
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 5, offset: const Offset(0, 5))
                  ]
                ),
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: ClockPainter(hour, minute),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Time Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeButton('- 1 Hr', () => _changeTime(h: -1), Colors.blue.shade100, Colors.blue.shade900),
                  _buildTimeButton('+ 1 Hr', () => _changeTime(h: 1), Colors.blue.shade100, Colors.blue.shade900),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeButton('- 5 Min', () => _changeTime(m: -5), Colors.orange.shade100, Colors.orange.shade900),
                  _buildTimeButton('+ 5 Min', () => _changeTime(m: 5), Colors.orange.shade100, Colors.orange.shade900),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.check_circle, size: 28),
                onPressed: _checkAnswer,
                label: const Text('Submit Answer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onPressed, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// Custom Clock Drawing Logic
class ClockPainter extends CustomPainter {
  final int hour;
  final int minute;

  ClockPainter(this.hour, this.minute);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final bgPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.indigo.shade900..style = PaintingStyle.stroke..strokeWidth = 8;
    
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawCircle(center, radius, borderPaint);

    // Draw markings
    final markPaint = Paint()..color = Colors.black54..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final startX = center.dx + radius * 0.85 * cos(angle);
      final startY = center.dy + radius * 0.85 * sin(angle);
      final endX = center.dx + radius * 0.95 * cos(angle);
      final endY = center.dy + radius * 0.95 * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), markPaint);
    }

    // Calculate hand angles
    final minAngle = (minute * 6 - 90) * pi / 180;
    final hrAngle = ((hour % 12) * 30 + (minute * 0.5) - 90) * pi / 180;

    // Draw Minute Hand
    final minHandPaint = Paint()..color = Colors.blue.shade700..strokeWidth = 5..strokeCap = StrokeCap.round;
    final minHandX = center.dx + radius * 0.75 * cos(minAngle);
    final minHandY = center.dy + radius * 0.75 * sin(minAngle);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandPaint);

    // Draw Hour Hand
    final hrHandPaint = Paint()..color = Colors.black87..strokeWidth = 8..strokeCap = StrokeCap.round;
    final hrHandX = center.dx + radius * 0.5 * cos(hrAngle);
    final hrHandY = center.dy + radius * 0.5 * sin(hrAngle);
    canvas.drawLine(center, Offset(hrHandX, hrHandY), hrHandPaint);

    // Draw Center Dot
    canvas.drawCircle(center, 8, Paint()..color = Colors.indigo);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}