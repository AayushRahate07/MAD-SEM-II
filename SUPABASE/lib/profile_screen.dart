import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  bool _isUploading = false;

  // Controllers
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final file = File(image.path);

      // Upload using the helper or direct logic
      final fileExt = image.path.split('.').last;
      final fileName = '$userId.$fileExt';

      await _supabase.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from('avatars').getPublicUrl(fileName);

      // Save URL to the profiles table
      await _supabase.from('profiles').update({'avatar_url': url}).eq('id', userId);

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Photo Updated!", style: lexendStyle())));
    } catch (e) {
      _showError("Upload failed: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  TextStyle lexendStyle({double size = 14, Color color = Colors.white, FontWeight weight = FontWeight.normal}) {
    return GoogleFonts.lexend(fontSize: size, color: color, fontWeight: weight);
  }

  // --- LOGIC: UPDATE SCHOOL/GRADE ---
  Future<void> _saveGeneralInfo() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('profiles').update({
        'school': _schoolController.text.trim(),
        'grade': _gradeController.text.trim(),
      }).eq('id', _supabase.auth.currentUser!.id);

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Info Updated!", style: lexendStyle())));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC: UPDATE PASSWORD ---
  Future<void> _updatePassword() async {
    if (_passController.text != _confirmPassController.text) {
      _showError("Passwords do not match!");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: _passController.text.trim()));
      _passController.clear();
      _confirmPassController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password Changed!", style: lexendStyle())));
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: lexendStyle(color: Colors.redAccent))));
  }

  @override
  Widget build(BuildContext context) {
    const Color deepNavy = Color(0xFF000C2D);
    const Color themeYellow = Color(0xFFFFC741);
    const Color petalPink = Color(0xFFFF80AB); // From your login.dart

    return Scaffold(
      backgroundColor: deepNavy,
      appBar: AppBar(
        title: Text("PLAYER SETTINGS", style: lexendStyle(size: 18, weight: FontWeight.w500, color: Colors.white70)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: themeYellow,
          labelStyle: lexendStyle(weight: FontWeight.bold),
          tabs: const [
            Tab(text: "PROFILE", icon: Icon(Icons.badge_outlined)),
            Tab(text: "SECURITY", icon: Icon(Icons.lock_outline)),
          ],
        ),
      ),

      extendBodyBehindAppBar: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              petalPink.withOpacity(0.2),
              const Color(0xFF5D3DF8).withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.25, 0.5],
          ),
        ),
        child: Stack(
          children: [
            // 1. THE GRID SYSTEM
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: MagicGridPainter()),
              ),
            ),

            // 3. YOUR TAB CONTENT
            StreamBuilder(
              stream: _supabase.from('profiles').stream(primaryKey: ['id']).eq('id', _supabase.auth.currentUser!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: themeYellow));

                final data = snapshot.data!.first;
                _schoolController.text = data['school'] ?? "";
                _gradeController.text = data['grade'] ?? "";

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(data, themeYellow, deepNavy),
                    _buildSecurityTab(themeYellow, deepNavy),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(Map data, Color yellow, Color navy) {
    bool isComplete = data['school'] != null && data['grade'] != null;
    String? avatarUrl = data['avatar_url'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          // --- PHOTO SECTION ---
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: yellow.withOpacity(0.1),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person_add_rounded, size: 40, color: yellow)
                      : null,
                ),
                if (_isUploading)
                  const SizedBox(width: 110, height: 110, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: yellow,
                    child: Icon(Icons.camera_alt, size: 18, color: navy),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          if (!isComplete) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: yellow.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: yellow)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(child: Text("Complete your profile to save your progress!", style: lexendStyle(size: 12, color: yellow))),
              ]),
            ),
          ],
          _buildField("SCHOOL NAME", _schoolController),
          _buildField("GRADE (E.G. 8TH)", _gradeController),
          const SizedBox(height: 30),
          _buildActionBtn("SAVE PROFILE INFO", _saveGeneralInfo, yellow, navy),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(Color yellow, Color navy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Text("CHANGE PASSWORD", style: lexendStyle(size: 16, weight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildField("NEW PASSWORD", _passController, isPass: true),
          _buildField("CONFIRM NEW PASSWORD", _confirmPassController, isPass: true),
          const SizedBox(height: 30),
          _buildActionBtn("UPDATE PASSWORD", _updatePassword, yellow, navy),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: lexendStyle(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: lexendStyle(size: 10, color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onPress, Color yellow, Color navy) {
    return _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPress,
      child: Text(label, style: lexendStyle(color: navy, weight: FontWeight.bold)),
    );
  }
}

Widget _buildBackgroundSymbol(String char, {double? top, double? left, double? bottom, double? right}) {
  return Positioned(
    top: top, left: left, bottom: bottom, right: right,
    child: Opacity(
      opacity: 0.05,
      child: Text(
          char,
          style: GoogleFonts.lexend(fontSize: 280, color: Colors.white, fontWeight: FontWeight.w900)
      ),
    ),
  );
}

class MagicGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 0.5;
    double step = 55.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}