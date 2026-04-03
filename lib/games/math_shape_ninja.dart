import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MathShapeNinjaGame extends StatefulWidget {
  const MathShapeNinjaGame({super.key});

  @override
  State<MathShapeNinjaGame> createState() => _MathShapeNinjaGameState();
}

class FallingShape {
  String id;
  double x;
  double y;
  String emoji;
  bool isCorrect;
  bool isSliced = false;

  FallingShape({
    required this.id,
    required this.x,
    required this.y,
    required this.emoji,
    required this.isCorrect,
  });
}

class GameQuestion {
  final String questionText;
  final String correctEmoji;
  final List<String> allEmojis;

  GameQuestion({
    required this.questionText,
    required this.correctEmoji,
    required this.allEmojis,
  });
}

class _MathShapeNinjaGameState extends State<MathShapeNinjaGame> {
  int score = 0;
  int timeLeft = 30;
  Timer? gameLoop;
  Timer? spawnTimer;
  List<FallingShape> shapes = [];
  final Random random = Random();

  // --- THE EXPANDED MOON-ONLY QUESTION BANK ---
  final List<String> moonPhases = ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"];

  late final List<GameQuestion> questionBank = [
    GameQuestion(
      questionText: "Catch the Half Moon! (Right side bright)",
      correctEmoji: "🌓",
      allEmojis: moonPhases,
    ),
    GameQuestion(
      questionText: "Catch the Half Moon! (Left side bright)",
      correctEmoji: "🌗",
      allEmojis: moonPhases,
    ),
    GameQuestion(
      questionText: "Which phase represents a whole? (1/1)",
      correctEmoji: "🌕",
      allEmojis: moonPhases,
    ),
    GameQuestion(
      questionText: "Which phase represents zero? (0/1)",
      correctEmoji: "🌑",
      allEmojis: moonPhases,
    ),
    GameQuestion(
      questionText: "Catch the Waxing Crescent! (~1/4 bright)",
      correctEmoji: "🌒",
      allEmojis: moonPhases,
    ),
    GameQuestion(
      questionText: "Catch the Waxing Gibbous! (~3/4 bright)",
      correctEmoji: "🌔",
      allEmojis: moonPhases,
    ),
  ];

  late GameQuestion currentQuestion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  void _startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      shapes.clear();
      // Pick a random moon question for this round
      currentQuestion = questionBank[random.nextInt(questionBank.length)];
    });

    // Main Game Loop (~60 FPS)
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      setState(() {
        for (var shape in shapes) {
          shape.y += 5.0; // Fall speed
        }
        shapes.removeWhere((s) => s.y > MediaQuery.of(context).size.height);
      });
    });

    // Countdown Timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        timer.cancel();
        _endGame();
      }
    });

    // Spawner Loop
    spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (timeLeft > 0 && mounted) _spawnShape();
    });
  }

  void _spawnShape() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool spawnCorrect = random.nextDouble() < 0.35; // 35% chance to be the correct answer
    
    String shapeEmoji = spawnCorrect 
        ? currentQuestion.correctEmoji 
        : currentQuestion.allEmojis[random.nextInt(currentQuestion.allEmojis.length)];

    setState(() {
      shapes.add(FallingShape(
        id: DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(1000).toString(),
        x: random.nextDouble() * (screenWidth - 80), 
        y: -100, 
        emoji: shapeEmoji,
        isCorrect: shapeEmoji == currentQuestion.correctEmoji,
      ));
    });
  }

  void _sliceShape(FallingShape shape) {
    setState(() {
      if (shape.isCorrect) {
        score += 10;
      } else {
        score -= 5;
        if (score < 0) score = 0;
      }
      shapes.removeWhere((s) => s.id == shape.id);
    });
  }

  void _endGame() {
    gameLoop?.cancel();
    spawnTimer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("Time's Up!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your Final Score:", style: TextStyle(fontSize: 18, color: Colors.white70)),
            Text("$score", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _startGame(); 
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: const Text('Exit', style: TextStyle(color: Colors.white54)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inherits the dark background from your main.dart
    return Scaffold(
      backgroundColor: const Color(0xFF00195A), // Matches your GanitControlCenter background!
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('⏱️ $timeLeft s', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('⭐ Score: $score', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black26,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Question Header
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black45, // Clean, dark, translucent box
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                currentQuestion.questionText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Instruction Text
          const Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Swipe or tap the correct moons!",
                style: TextStyle(color: Colors.white54, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ),

          // Render all active shapes
          ...shapes.map((shape) {
            return Positioned(
              left: shape.x,
              top: shape.y,
              child: GestureDetector(
                onPanDown: (_) => _sliceShape(shape), 
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Text(
                      shape.emoji,
                      style: const TextStyle(
                        fontSize: 60, 
                        color: Colors.black // Forces black emoji tint where applicable
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}