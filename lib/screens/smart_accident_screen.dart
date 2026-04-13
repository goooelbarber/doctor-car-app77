import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import 'road_services_screen.dart';

class SmartAccidentScreen extends StatefulWidget {
  const SmartAccidentScreen({super.key});

  @override
  State<SmartAccidentScreen> createState() => _SmartAccidentScreenState();
}

class _SmartAccidentScreenState extends State<SmartAccidentScreen>
    with TickerProviderStateMixin {
  static const Color _bgStart = Color(0xFF081A36);
  static const Color _bgMid = Color(0xFF0B2348);
  static const Color _bgEnd = Color(0xFF040D1D);

  // ignore: unused_field
  static const Color _panel = Color(0xFF143F7C);
  // ignore: unused_field
  static const Color _panelDark = Color(0xFF102C54);
  static const Color _accent = Color(0xFF1B4F9C);
  static const Color _accentDark = Color(0xFF10386B);
  static const Color _accentSoft = Color(0xFFE7EEF9);
  static const Color _accentGlow = Color(0xFF7CC4F5);

  static const Color _danger = Color(0xFFFF5A52);
  static const Color _dangerDark = Color(0xFFD8343A);
  static const Color _success = Color(0xFF36C690);
  static const Color _warning = Color(0xFFFFB84D);

  static const Color _text = Color(0xFFF2F6FB);
  static const Color _muted = Color(0xFFC9D6EA);

  static const String _kEmergencyContactKey = 'emergency_contact_data_v1';

  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactPhoneCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  late final AnimationController _glowController;
  late final AnimationController _pulseController;

  bool _loadingLocation = false;
  bool _sendingEmergency = false;
  bool _savingContact = false;
  bool _isRecording = false;

  Position? _currentPosition;
  String? _locationText;
  String? _resolvedAddress;

  List<File> _pickedImages = [];
  String? _audioPath;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  EmergencyContact? _emergencyContact;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _loadEmergencyContact();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _notesCtrl.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEmergencyContactKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final contact = EmergencyContact.fromJson(map);
      if (!mounted) return;
      setState(() {
        _emergencyContact = contact;
        _contactNameCtrl.text = contact.name;
        _contactPhoneCtrl.text = contact.phone;
      });
    } catch (_) {}
  }

  Future<void> _saveEmergencyContact() async {
    final name = _contactNameCtrl.text.trim();
    final phone = _contactPhoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnack('اكتب اسم ورقم جهة الطوارئ');
      return;
    }

    setState(() => _savingContact = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final contact = EmergencyContact(name: name, phone: phone);

      await prefs.setString(
        _kEmergencyContactKey,
        jsonEncode(contact.toJson()),
      );

      if (!mounted) return;
      setState(() {
        _emergencyContact = contact;
      });

      _showSnack('تم حفظ جهة اتصال الطوارئ');
    } finally {
      if (mounted) setState(() => _savingContact = false);
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _loadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('فعّل الموقع أولًا');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('لم يتم منح صلاحية الموقع');
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationText =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        _resolvedAddress = 'الموقع الحالي جاهز للإرسال';
      });
    } catch (_) {
      _showSnack('تعذر تحديد الموقع');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _callEmergencyNumber() async {
    final uri = Uri.parse('tel:123');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('تعذر فتح الاتصال');
    }
  }

  Future<void> _callEmergencyContact() async {
    if (_emergencyContact == null) {
      _showSnack('أضف جهة اتصال طوارئ أولًا');
      return;
    }

    final uri = Uri.parse('tel:${_emergencyContact!.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('تعذر الاتصال بجهة الطوارئ');
    }
  }

  Future<void> _shareLiveLocationToContact() async {
    if (_emergencyContact == null) {
      _showSnack('أضف جهة اتصال طوارئ أولًا');
      return;
    }

    await _loadCurrentLocation();
    if (_currentPosition == null) return;

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    final mapUrl = 'https://maps.google.com/?q=$lat,$lng';
    final smsBody = 'تعرضت لحادث، هذا موقعي الحالي: $mapUrl';

    final uri = Uri.parse(
      'sms:${_emergencyContact!.phone}?body=${Uri.encodeComponent(smsBody)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('تعذر إرسال الرسالة');
    }
  }

  Future<void> _pickAccidentImages() async {
    try {
      final result = await _picker.pickMultiImage(imageQuality: 80);
      if (result.isEmpty) return;

      if (!mounted) return;
      setState(() {
        final files = result.map((e) => File(e.path)).toList();
        _pickedImages = files.take(4).toList();
      });
    } catch (_) {
      _showSnack('تعذر اختيار الصور');
    }
  }

  Future<void> _addPhotoFromCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (file == null) return;

      if (!mounted) return;
      setState(() {
        if (_pickedImages.length < 4) {
          _pickedImages.add(File(file.path));
        }
      });
    } catch (_) {
      _showSnack('تعذر فتح الكاميرا');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      try {
        final path = await _recorder.stop();
        _recordTimer?.cancel();

        if (!mounted) return;
        setState(() {
          _audioPath = path;
          _isRecording = false;
        });
        _showSnack('تم حفظ التسجيل الصوتي');
      } catch (_) {
        _showSnack('تعذر إيقاف التسجيل');
      }
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _showSnack('مطلوب إذن الميكروفون');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/accident_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(),
        path: path,
      );

      _recordDuration = Duration.zero;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRecording) return;
        setState(() {
          _recordDuration += const Duration(seconds: 1);
        });
      });

      if (!mounted) return;
      setState(() {
        _isRecording = true;
      });
      _showSnack('بدأ تسجيل الملاحظة الصوتية');
    } catch (_) {
      _showSnack('تعذر بدء التسجيل');
    }
  }

  Future<void> _sendEmergencyRequest() async {
    await _loadCurrentLocation();

    if (_currentPosition == null) {
      _showSnack('لازم تحديد الموقع أولًا');
      return;
    }

    setState(() => _sendingEmergency = true);

    try {
      final res = await ApiService.submitEmergencyCase(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _resolvedAddress ?? _locationText,
        notes: _notesCtrl.text.trim(),
        imagePaths: _pickedImages.map((e) => e.path).toList(),
        audioPath: _audioPath,
        emergencyContactName: _contactNameCtrl.text.trim(),
        emergencyContactPhone: _contactPhoneCtrl.text.trim(),
        serviceType: 'accident',
      );

      final message = (res['message'] ?? '').toString();

      final routeMissing = message.contains('Route not found') ||
          message.contains('/accidents/emergency');

      if (res['error'] == true && !routeMissing) {
        _showSnack(message.isNotEmpty ? message : 'تعذر إرسال طلب الطوارئ');
        return;
      }

      if (routeMissing) {
        _showSnack('تم تشغيل وضع الطوارئ محليًا لحين ربط السيرفر');
      } else {
        await ApiService.sendEmergencyNotification(
          title: 'بلاغ حادث جديد',
          body: 'تم إرسال بلاغ حادث من التطبيق',
          data: {
            'type': 'accident_emergency',
            'lat': _currentPosition!.latitude,
            'lng': _currentPosition!.longitude,
          },
        );
      }

      if (!mounted) return;
      _showSuccessBottomSheet();
    } catch (_) {
      _showSnack('تعذر إرسال طلب الطوارئ');
    } finally {
      if (mounted) setState(() => _sendingEmergency = false);
    }
  }

  void _goToTowService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoadServicesScreen(initialServiceKey: 'tow'),
      ),
    );
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF102744),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _success.withOpacity(.16),
                    border: Border.all(color: _success.withOpacity(.28)),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _success,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'تم إرسال طلب المساعدة',
                  style: GoogleFonts.cairo(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تم إرسال الموقع والمرفقات الحالية بنجاح، وتقدر الآن تطلب ونش أو تتواصل مع الطوارئ مباشرة.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: _muted,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _primaryButton(
                        text: 'طلب ونش',
                        icon: Icons.local_shipping_rounded,
                        onTap: () {
                          Navigator.pop(context);
                          _goToTowService();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _secondaryButton(
                        text: 'إغلاق',
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF14304F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _pulseController]),
      builder: (_, __) {
        return Scaffold(
          backgroundColor: _bgStart,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'مساعدة فورية بعد الحادث',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          body: Stack(
            children: [
              _background(),
              SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroCard(),
                      const SizedBox(height: 14),
                      _quickStatusStrip(),
                      const SizedBox(height: 14),
                      _statusGrid(),
                      const SizedBox(height: 14),
                      _locationCard(),
                      const SizedBox(height: 14),
                      _mediaSection(),
                      const SizedBox(height: 14),
                      _emergencyContactCard(),
                      const SizedBox(height: 14),
                      _notesCard(),
                      const SizedBox(height: 18),
                      _mainEmergencyButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _background() {
    final glow = _glowController.value;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgStart, _bgMid, _bgEnd],
              ),
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -30,
          child: _blurGlow(
            size: 240,
            color: _accentGlow.withOpacity(.12 + glow * .05),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -20,
          child: _blurGlow(
            size: 220,
            color: _danger.withOpacity(.08),
          ),
        ),
      ],
    );
  }

  Widget _blurGlow({required double size, required Color color}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1A4276),
            Color(0xFF12315C),
            Color(0xFF0D2343),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: _accentGlow.withOpacity(.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تصرف سريع وآمن',
                  style: GoogleFonts.cairo(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حدد حالتك الآن، أرسل موقعك، تواصل مع الطوارئ، وارفع صور الحادث في خطوات قليلة.',
                  style: GoogleFonts.cairo(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.4,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroChip(
                      icon: Icons.location_on_rounded,
                      text: _currentPosition != null
                          ? 'الموقع جاهز'
                          : 'حدد موقعك',
                    ),
                    _heroChip(
                      icon: Icons.shield_rounded,
                      text: 'حماية أسرع',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Transform.scale(
            scale: 1 + (_pulseController.value * .06),
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [_danger, _dangerDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _danger.withOpacity(.25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStatusStrip() {
    return Row(
      children: [
        Expanded(
          child: _statusPill(
            icon: Icons.image_rounded,
            label: '${_pickedImages.length}/4 صور',
            color: _accentGlow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statusPill(
            icon:
                _audioPath != null ? Icons.mic_rounded : Icons.mic_none_rounded,
            label: _audioPath != null
                ? 'ملاحظة صوتية جاهزة'
                : (_isRecording
                    ? _formatDuration(_recordDuration)
                    : 'بدون صوت'),
            color: _warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statusPill(
            icon: Icons.contact_phone_rounded,
            label: _emergencyContact != null ? 'جهة محفوظة' : 'أضف جهة',
            color: _success,
          ),
        ),
      ],
    );
  }

  Widget _statusPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.16),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: _text,
                fontWeight: FontWeight.w800,
                fontSize: 11.6,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                color: _success,
                icon: Icons.check_circle_rounded,
                title: 'أنا بخير',
                subtitle: 'طلب ونش أو خدمة فقط',
                onTap: _goToTowService,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                color: _danger,
                icon: Icons.sos_rounded,
                title: 'مساعدة فورية',
                subtitle: 'إرسال طلب نجدة الآن',
                onTap: _sendEmergencyRequest,
                isPrimary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                color: _warning,
                icon: Icons.phone_in_talk_rounded,
                title: 'اتصال طوارئ',
                subtitle: 'اتصل فورًا',
                onTap: _callEmergencyNumber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                color: _accentGlow,
                icon: Icons.send_to_mobile_rounded,
                title: 'إرسال الموقع',
                subtitle: 'SMS لجهة الطوارئ',
                onTap: _shareLiveLocationToContact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    color.withOpacity(.24),
                    color.withOpacity(.12),
                  ],
                )
              : null,
          color: isPrimary ? null : color.withOpacity(.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(.28)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(.22),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fancyIconBadge(
              color: color,
              icon: icon,
              highlight: isPrimary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: _text,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                color: _muted,
                fontWeight: FontWeight.w700,
                fontSize: 12.2,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fancyIconBadge({
    required Color color,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(highlight ? .30 : .22),
            color.withOpacity(highlight ? .14 : .10),
          ],
        ),
        border: Border.all(color: color.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(highlight ? .20 : .10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ),
          Icon(icon, color: color, size: 28),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return _sectionCard(
      title: 'الموقع الحالي',
      icon: Icons.location_on_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _loadingLocation
                      ? 'جارٍ تحديد الموقع...'
                      : (_locationText ?? 'لم يتم تحديد الموقع بعد'),
                  style: GoogleFonts.cairo(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _smallButton(
                text: 'تحديث',
                icon: Icons.refresh_rounded,
                onTap: _loadCurrentLocation,
              ),
            ],
          ),
          if (_resolvedAddress != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _resolvedAddress!,
                style: GoogleFonts.cairo(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mediaSection() {
    return _sectionCard(
      title: 'توثيق الحادث',
      icon: Icons.perm_media_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _smallButton(
                  text: 'رفع صور',
                  icon: Icons.photo_library_rounded,
                  onTap: _pickAccidentImages,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallButton(
                  text: 'التقاط صورة',
                  icon: Icons.camera_alt_rounded,
                  onTap: _addPhotoFromCamera,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallButton(
                  text: _isRecording ? 'إيقاف التسجيل' : 'تسجيل صوتي',
                  icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  onTap: _toggleRecording,
                ),
              ),
            ],
          ),
          if (_pickedImages.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الصور المرفوعة',
                style: GoogleFonts.cairo(
                  color: _text,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final file = _pickedImages[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          file,
                          width: 92,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: InkWell(
                          onTap: () {
                            setState(() => _pickedImages.removeAt(i));
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.58),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          if (_audioPath != null || _isRecording) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _warning.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _warning.withOpacity(.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _warning.withOpacity(.16),
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.graphic_eq_rounded
                          : Icons.audio_file_rounded,
                      color: _warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? 'جارٍ التسجيل: ${_formatDuration(_recordDuration)}'
                          : 'تم حفظ ملاحظة صوتية',
                      style: GoogleFonts.cairo(
                        color: _text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (_audioPath != null && !_isRecording)
                    TextButton(
                      onPressed: () {
                        setState(() => _audioPath = null);
                      },
                      child: const Text('حذف'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emergencyContactCard() {
    return _sectionCard(
      title: 'جهة اتصال الطوارئ',
      icon: Icons.contact_phone_rounded,
      child: Column(
        children: [
          TextField(
            controller: _contactNameCtrl,
            style: const TextStyle(color: _text),
            decoration:
                _inputDecoration('اسم الشخص', Icons.person_outline_rounded),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactPhoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: _text),
            decoration: _inputDecoration('رقم الهاتف', Icons.phone_rounded),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _primaryButton(
                  text: _savingContact ? 'جارٍ الحفظ...' : 'حفظ جهة الطوارئ',
                  icon: Icons.save_rounded,
                  onTap: _savingContact ? null : _saveEmergencyContact,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _secondaryButton(
                  text: 'اتصال مباشر',
                  icon: Icons.call_rounded,
                  onTap: _callEmergencyContact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notesCard() {
    return _sectionCard(
      title: 'ملاحظات سريعة',
      icon: Icons.edit_note_rounded,
      child: TextField(
        controller: _notesCtrl,
        minLines: 3,
        maxLines: 5,
        style: const TextStyle(color: _text),
        decoration: _inputDecoration(
          'اكتب وصف مختصر للحادث أو حالتك',
          Icons.description_outlined,
        ),
      ),
    );
  }

  Widget _mainEmergencyButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [_danger, _dangerDark],
          ),
          boxShadow: [
            BoxShadow(
              color: _danger.withOpacity(.25),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _sendingEmergency ? null : _sendEmergencyRequest,
            child: Center(
              child: _sendingEmergency
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emergency_rounded,
                            color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'إرسال طلب مساعدة الآن',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _sectionIcon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: _text,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _sectionIcon(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [_accent, _accentDark],
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(.20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _smallButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentSoft,
          side: BorderSide(color: Colors.white.withOpacity(.12)),
          backgroundColor: Colors.white.withOpacity(.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentSoft,
          side: BorderSide(color: Colors.white.withOpacity(.12)),
          backgroundColor: Colors.white.withOpacity(.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _muted.withOpacity(.75)),
      prefixIcon: Icon(icon, color: _accentSoft),
      filled: true,
      fillColor: Colors.white.withOpacity(.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accentGlow),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}
