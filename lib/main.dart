import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathquest/games/bazaar_bill.dart';
import 'package:mathquest/games/samay_sudhaar.dart';
import 'package:mathquest/games/math_shape_ninja.dart';
void main() {
  runApp(const MathQuestApp());
}

class MathQuestApp extends StatelessWidget {
  const MathQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MATH QUEST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF254FBD),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GanitControlCenter(),
    );
  }
}

class GanitControlCenter extends StatelessWidget {
  const GanitControlCenter({super.key});

  final List<Map<String, String>> games = const [
    {"title": "BAZAAR BILL", "img": "assets/1.png"},
    {"title": "FORMULA FLASH", "img": "assets/6.png"},
    {"title": "PAIR UP", "img": "assets/5.png"},
    {"title": "GRID GUARDIAN", "img": "assets/3.png"},
    {"title": "TARGET BLITZZ", "img": "assets/4.png"},
    {"title": "QUICK TICK", "img": "assets/7.png"},
    {"title": "FRACTION FIELD", "img": "assets/8.png"},
    {"title": "SHAPE SURGE", "img": "assets/2.png"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF00195A);

    return Scaffold(
      backgroundColor: darkBlue,
      body: Stack(
        children: [
          // --- LAYER 1: THE GRID BACKGROUND ---
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // --- LAYER 2: THE UI CONTENT ---
          LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth > 1200 ? 150 : 40;

              return ScrollConfiguration(
                behavior: NoThumbScrollBehavior(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // --- HEADER SECTION ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100, bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "PERSONALISED MATH PLATFORM",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 4,
                                fontWeight: FontWeight.w300,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "MATH QUEST",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 8,
                                fontSize: 35,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: 65,
                              height: 2,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),

                    // --- 2-COLUMN RECTANGULAR GRID ---
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => GameModuleCard(
                            key: ValueKey(games[index]["title"]),
                            title: games[index]["title"]!,
                            imagePath: games[index]["img"]!,
                            accentColor: Colors.white,
                          ),
                          childCount: games.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 30,
                          childAspectRatio: 1.6, // Leaves space for centered title below image
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GameModuleCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color accentColor;

  const GameModuleCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.accentColor,
  });

  @override
  State<GameModuleCard> createState() => _GameModuleCardState();
}

class _GameModuleCardState extends State<GameModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      // Wrap the card in a GestureDetector to handle clicks
      child: GestureDetector(
        onTap: () {
          // Route to Bazaar Bill
          if (widget.title == "BAZAAR BILL") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BazaarBillGame(),
              ),
            );
          } 
          // Route to Clock Game (Mapping to QUICK TICK)
          else if (widget.title == "QUICK TICK") { 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SamaySudhaarGame(),
              ),
            );
          }
          // Route to Fruit Ninja Shape Game (Mapping to SHAPE SURGE)
          else if (widget.title == "SHAPE SURGE") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MathShapeNinjaGame(),
              ),
            );
          }
          // Add more else-if blocks here as you build the other games!
        },
        // child: AnimatedScale(
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sharp Edge Rectangular Card (1.95 Ratio)
              AspectRatio(
                aspectRatio: 1.95,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    border: Border.all(
                      width: 0.5,
                      color: _isHovered
                          ? widget.accentColor
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                    ] : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Centered Game Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 1.5,
                  color: _isHovered ? Colors.white : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the Light Grid Background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    const double step = 45;

    // Vertical grid lines
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal grid lines
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Clean Scroll Behavior
class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(context, child, details) => child;
}