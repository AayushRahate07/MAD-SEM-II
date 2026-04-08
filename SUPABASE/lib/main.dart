import 'package:flutter/material.dart';
import 'package:mathquest/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathquest/games/bazaar_bill.dart';
import 'package:mathquest/games/formula_flash.dart';
import 'package:mathquest/games/fraction_fields.dart';
import 'package:mathquest/games/shape_surge.dart';
import 'package:mathquest/games/quick_tick.dart';
import 'package:mathquest/splash_screen.dart';
import 'package:mathquest/supa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mathquest/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://invfekooeeuiiblcdbyt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImludmZla29vZWV1aWlibGNkYnl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1NzcxNTgsImV4cCI6MjA5MTE1MzE1OH0.3kH71qvxOEPVYsD-gKmU1RjztSCH-IsNKlwpMCJ7Jgo',
  );

  runApp(const MathQuestApp());
}

final supabase = Supabase.instance.client;

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
          seedColor: const Color(0xFF80D8FF),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
      ),
      routes: {
        '/': (context) => const MathQuestLoading(),
        '/login': (context) => const MathQuestLogin(),
        '/home': (context) => const GanitControlCenter(),
      },
      initialRoute: '/',
    );
  }
}

class GanitControlCenter extends StatelessWidget {
  const GanitControlCenter({super.key});

  final List<Map<String, String>> games = const [
    {"title": "BAZAAR BILL", "img": "assets/1.png"},
    {"title": "FORMULA FLASH", "img": "assets/6.png"},
    {"title": "FRACTION FIELD", "img": "assets/8.png"},
    {"title": "QUICK TICK", "img": "assets/7.png"},
    {"title": "SHAPE SURGE", "img": "assets/2.png"},
    {"title": "PAIR UP", "img": "assets/5.png"},
    {"title": "GRID GUARDIAN", "img": "assets/3.png"},
    {"title": "TARGET BLITZZ", "img": "assets/4.png"},
  ];

  @override
  Widget build(BuildContext context) {
    const Color deepNavy = Color(0xFF000C2D);
    const Color themeYellow = Color(0xFFFFC741);

    return Scaffold(
      backgroundColor: deepNavy,
      // 1. ADD APPBAR FOR THE HAMBURGER ICON
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
      // 2. ADD THE DRAWER (SIDEBAR)
      drawer: Drawer(
        backgroundColor: deepNavy,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.transparent, width: 0)),
                  image: DecorationImage(
                    image: AssetImage("assets/drawer.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const SizedBox.shrink(),
              ),
            ),
            _buildDrawerItem(Icons.person_outline, "Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }),
            _buildDrawerItem(Icons.info_outline, "Instructions", () {
              _showInstructions(context);
            }),
            const Spacer(),
            _buildDrawerItem(Icons.logout_rounded, "LOG OUT", () async {
              await SupaService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            }, color: Colors.redAccent),
            const SizedBox(height: 60),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          LayoutBuilder(
            builder: (context, constraints) {
              double hPadding = constraints.maxWidth > 800 ? 80 : 30;

              return ScrollConfiguration(
                behavior: NoThumbScrollBehavior(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 30,
                          childAspectRatio: 1.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => GameModuleCard(
                            title: games[index]["title"]!,
                            imagePath: games[index]["img"]!,
                          ),
                          childCount: games.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000C2D),
        title: Text("HOW TO PLAY", style: GoogleFonts.lexend(color: const Color(0xFFFFC741))),
        content: Text(
          "Select a module to start your training. Complete equations to earn XP and level up your adventurer!",
          style: GoogleFonts.lexend(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("GOT IT"),
          )
        ],
      ),
    );
  }
}

class GameModuleCard extends StatefulWidget {
  final String title;
  final String imagePath;

  const GameModuleCard({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  State<GameModuleCard> createState() => _GameModuleCardState();
}

class _GameModuleCardState extends State<GameModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        switch (widget.title) {
          case "BAZAAR BILL":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BazaarBillGame()));
            break;
          case "FORMULA FLASH":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FormulaFlashGame()));
            break;
          case "FRACTION FIELD":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FractionApp()));
            break;
          case "QUICK TICK":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SamaySudhaarGame()));
            break;
          case "SHAPE SURGE":
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MathShapeNinjaGame()));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${widget.title} coming soon!")),
            );
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero,
            image: DecorationImage(
              image: AssetImage(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.zero,
              // 2. REMOVED SHADING: Gradient is gone
              color: Colors.transparent, // Fully transparent inner box
            ),
            // Padding and alignment are kept just in case you ever want to put something back
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            // 3. REMOVED TEXT: Text(widget.title) is gone
            child: const SizedBox.shrink(), // Minimal empty child
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    const double step = 50;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(context, child, details) => child;
}