import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FractionApp extends StatelessWidget {
  const FractionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GameScreen();
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestion = 1;
  final int totalQuestions = 5;

  late int multiplicand, correctAnswer;
  late String equationText;
  Set<int> harvestedIndices = {};

  final Color softBlue = const Color(0xFF80D8FF);
  final Color deepNavy = const Color(0xFF000C2D);

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    final rand = Random();

    // Strategy: Create nested operations that result in a small number
    // Pattern: A + [B × (C - D)] or [(A + B) ÷ C] × D
    int mode = rand.nextInt(2);

    if (mode == 0) {
      // Pattern: A + [B × (C - D)]
      int d = rand.nextInt(3) + 1;       // 1-3
      int c = d + (rand.nextInt(3) + 1); // Ensures (C-D) is positive
      int b = rand.nextInt(3) + 2;       // 2-4
      int a = rand.nextInt(5) + 1;       // 1-5

      correctAnswer = a + (b * (c - d));
      equationText = "$a + [ $b × ( $c - $d ) ]";
    } else {
      // Pattern: [(A + B) ÷ C] × D
      int c = rand.nextInt(2) + 2;       // 2-3
      int multiplier = rand.nextInt(3) + 1;
      int sum = c * multiplier;          // Ensures division results in whole number
      int a = rand.nextInt(sum - 1) + 1;
      int b = sum - a;
      int d = rand.nextInt(2) + 2;       // 2-3

      correctAnswer = ((a + b) ~/ c) * d;
      equationText = "[($a + $b) ÷ $c] × $d";
    }

    // Fallback safety for the grid (Max 20 crops)
    if (correctAnswer > 20 || correctAnswer < 1) {
      generateQuestion(); // Re-roll if too large or small
      return;
    }

    multiplicand = (correctAnswer + rand.nextInt(3) + 2).clamp(5, 20);

    setState(() {
      harvestedIndices.clear();
    });
  }

  void toggleHarvest(int index) {
    if (index >= multiplicand) return;
    setState(() {
      if (harvestedIndices.contains(index)) {
        harvestedIndices.remove(index);
      } else {
        harvestedIndices.add(index);
      }
    });
  }

  void submitHarvest() {
    bool isCorrect = harvestedIndices.length == correctAnswer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildResultDialog(isCorrect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: THE FIELD BACKGROUND
          Positioned.fill(
            child: Image.asset('assets/field.png', fit: BoxFit.cover),
          ),

          // LAYER 2: SLIM TOP CONTROLS
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSlimButton("EXIT", Icons.close, () => Navigator.pop(context)),
                _buildSlimButton("RESET", Icons.refresh, () => setState(() => harvestedIndices.clear())),
              ],
            ),
          ),

          // LAYER 3: THE GAMEPLAY CONTENT
          Column(
            mainAxisAlignment: MainAxisAlignment.end, // Anchors everything to the bottom
            children: [
              // THE CROP FIELD
              SizedBox(
                height: 320, // Explicit height prevents overlap with the blue card
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      bool isAvailable = index < multiplicand;
                      bool isHarvested = harvestedIndices.contains(index);

                      return GestureDetector(
                        onTap: () => toggleHarvest(index),
                        child: isAvailable
                            ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isHarvested
                              ? Container(
                            key: ValueKey('basket_$index'),
                            child: const Icon(
                              Icons.shopping_basket_rounded, // THE LOGO
                              color: Colors.greenAccent,
                              size: 35,
                            ),
                          )
                              : Image.asset(
                            'assets/crop.png',
                            key: ValueKey('crop_$index'),
                            fit: BoxFit.contain,
                          ),
                        )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),

              // THE QUEST CARD
              _buildBottomQuestCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlimButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.lexend(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomQuestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: deepNavy.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("QUEST $currentQuestion/5", style: GoogleFonts.lexend(color: softBlue, fontWeight: FontWeight.w900)),
                // MAINTAINING COUNT OF HARVESTED CROPS
                Text("HARVESTED: ${harvestedIndices.length}", style: GoogleFonts.lexend(color: Colors.amber, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              equationText,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: submitHarvest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: softBlue,
                  foregroundColor: deepNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("SUBMIT HARVEST", style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDialog(bool isCorrect) {
    return AlertDialog(
      backgroundColor: deepNavy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      title: Text(isCorrect ? "PERFECT! 🌟" : "NOT QUITE!", textAlign: TextAlign.center,
          style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w900)),
      content: Text(
        isCorrect ? "The farmer is happy! You harvested the exact amount." : "The farmer needed $correctAnswer crops. Let's try again!",
        textAlign: TextAlign.center, style: GoogleFonts.lexend(color: Colors.white70),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentQuestion < totalQuestions) {
                setState(() => currentQuestion++);
                generateQuestion();
              } else {
                _showFinalResults();
              }
            },
            child: Text("CONTINUE", style: GoogleFonts.lexend(color: softBlue, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: deepNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 90),
            const SizedBox(height: 25),
            Text("HARVEST DONE!", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
            const SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: softBlue, minimumSize: const Size(200, 55)),
              onPressed: () {
                Navigator.pop(context);
                setState(() { currentQuestion = 1; });
                generateQuestion();
              },
              child: Text("PLAY AGAIN", style: GoogleFonts.lexend(color: deepNavy, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}