import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_car_app/screens/services/services_history_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollCtrl = ScrollController();

  bool _ttsEnabled = false;
  bool _accepted = false;
  bool _scrolledToEnd = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final LinearGradient _gold = const LinearGradient(
    colors: [Color(0xffE8C87A), Color(0xffB68A32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _init();
    _scrollCtrl.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 50) {
      setState(() => _scrolledToEnd = true);
    }
  }

  Future<void> _init() async {
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool("privacyAccepted") ?? false;

    if (accepted && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ServicesHistoryScreen()),
      );
    }
  }

  Future<void> _saveAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("privacyAccepted", true);
    await prefs.setString(
      "privacyAcceptedAt",
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showSnack("يجب الموافقة على سياسة الخصوصية أولاً");
        return false;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 1, 10, 23),
          appBar: _buildAppBar(),
          body: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _progressBar(),
                Expanded(child: _content()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (b) => _gold.createShader(b),
        child: Text(
          "سياسة الخصوصية",
          style: GoogleFonts.cairo(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _ttsEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() => _ttsEnabled = !_ttsEnabled);
            _ttsEnabled ? _speak(_privacyText) : _tts.stop();
          },
        ),
      ],
    );
  }

  // ---------------- PROGRESS ----------------

  Widget _progressBar() {
    return LinearProgressIndicator(
      value: _scrolledToEnd ? 1 : 0.4,
      color: Colors.amber,
      backgroundColor: Colors.white12,
      minHeight: 4,
    );
  }

  // ---------------- CONTENT ----------------

  Widget _content() {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _section(Icons.security, "حماية البيانات",
              "نلتزم بحماية بياناتك وعدم مشاركتها دون إذن."),
          _section(Icons.location_on, "استخدام الموقع",
              "يتم استخدام الموقع فقط لتقديم خدمات الطرق القريبة منك."),
          _section(Icons.camera_alt, "الكاميرا والميكروفون",
              "يتم الوصول للكاميرا أو الميكروفون عند طلبك فقط."),
          _section(Icons.delete_forever, "حذف الحساب",
              "يمكنك حذف حسابك وبياناتك نهائيًا في أي وقت."),
          _legalWarning(),
          CheckboxListTile(
            value: _accepted,
            activeColor: Colors.amber,
            title: Text(
              "أوافق على سياسة الخصوصية",
              style: GoogleFonts.cairo(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onChanged: !_scrolledToEnd
                ? null
                : (v) => setState(() => _accepted = v ?? false),
          ),
          _confirmButton(),
          const SizedBox(height: 20),
          _footer(),
        ],
      ),
    );
  }

  // ---------------- COMPONENTS ----------------

  Widget _section(IconData icon, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.white.withOpacity(.05),
            backgroundColor: Colors.white.withOpacity(.07),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(shape: BoxShape.circle, gradient: _gold),
              child: Icon(icon, color: Colors.black),
            ),
            title: Text(
              title,
              style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  text,
                  style: GoogleFonts.cairo(color: Colors.white70, height: 1.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legalWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "⚠️ بالموافقة، تقر بأنك قرأت السياسة وتوافق عليها قانونيًا.",
        style: GoogleFonts.cairo(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: () async {
        if (!_accepted || !_scrolledToEnd) {
          _showSnack("يجب قراءة السياسة كاملة والموافقة");
          return;
        }

        HapticFeedback.mediumImpact();
        await _saveAcceptance();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServicesHistoryScreen()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: _accepted && _scrolledToEnd ? _gold : null,
          color: !_accepted ? Colors.grey : null,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            "تأكيد والمواصلة",
            style: GoogleFonts.cairo(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Text(
          "آخر تحديث: 1 مارس 2025",
          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          "Doctor Car © ${DateTime.now().year}",
          style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: Colors.black87,
      ),
    );
  }

  final String _privacyText = """
نحن نحترم خصوصيتك.
لا نقوم بمشاركة بياناتك.
يتم استخدام الموقع فقط لتقديم الخدمة.
يمكنك حذف حسابك في أي وقت.
""";
}
