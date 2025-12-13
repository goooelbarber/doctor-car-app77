import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SmartAccidentScreen extends StatefulWidget {
  const SmartAccidentScreen({super.key});

  @override
  State<SmartAccidentScreen> createState() => _SmartAccidentScreenState();
}

class _SmartAccidentScreenState extends State<SmartAccidentScreen> {
  bool assistantEnabled = false;
  StreamSubscription? accelSub;
  double lastForce = 0.0;

  CameraController? camController;
  bool cameraReady = false;

  final backend = "http://192.168.1.11:5001"; // ← ضع IP السيرفر هنا

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    accelSub?.cancel();
    camController?.dispose();
    super.dispose();
  }

  // =============================
  // 🎥 1. تهيئة الكاميرا
  // =============================
  Future<void> initCamera() async {
    final cams = await availableCameras();
    camController = CameraController(cams.first, ResolutionPreset.medium);

    await camController!.initialize();
    setState(() => cameraReady = true);
  }

  // =============================
  // 🎥 2. تسجيل فيديو
  // =============================
  Future<File?> startRecording() async {
    if (!cameraReady) return null;

    await camController!.startVideoRecording();
    await Future.delayed(const Duration(seconds: 7));
    final file = await camController!.stopVideoRecording();

    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(file.path)
        .copy("${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4");

    return saved;
  }

  // =============================
  // 📍 3. تحديد الموقع
  // =============================
  Future<Map<String, dynamic>> getLocation() async {
    await Geolocator.requestPermission();
    Position pos = await Geolocator.getCurrentPosition();

    return {
      "lat": pos.latitude,
      "lng": pos.longitude,
      "date": DateTime.now().toString(),
      "force": lastForce
    };
  }

  // =============================
  // 🛰 4. رفع فيديو للسيرفر
  // =============================
  Future<String?> uploadVideo(File video) async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("$backend/api/accidents/upload"));

    request.files.add(await http.MultipartFile.fromPath(
      "video",
      video.path,
      filename: basename(video.path),
    ));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final decoded = jsonDecode(body);

    return decoded["url"]; // رابط الفيديو على السيرفر
  }

  // =============================
  // 🚨 5. إرسال بيانات الحادث
  // =============================
  Future<void> sendAccident(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse("$backend/api/accidents"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // =============================
  // 🚨 6. Firebase Notification
  // =============================
  Future<void> sendPush(String title, String body) async {
    await http.post(
      Uri.parse("$backend/api/accidents/notify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "body": body}),
    );
  }

  // =============================
  // 🚨 7. اكتشاف حادث حقيقي
  // =============================
  Future<void> handleAccident() async {
    showSnack("⚠️ تم اكتشاف حادث…");

    final videoFile = await startRecording();
    if (videoFile == null) return;

    final loc = await getLocation();

    final videoUrl = await uploadVideo(videoFile);

    loc["video"] = videoUrl ?? "";

    await sendAccident(loc);

    await sendPush(
        "حادث جديد", "تم اكتشاف حادث عند ${loc['lat']}, ${loc['lng']}");

    showSnack("✔ تم حفظ الحادث وإرسال الإشعارات");
  }

  // =============================
  // 📡 8. تفعيل حساس التصادم
  // =============================
  void activateAssistant() {
    if (assistantEnabled) return;

    assistantEnabled = true;
    showSnack("🚗 تم تفعيل نظام اكتشاف الحوادث");

    // ignore: deprecated_member_use
    accelSub = accelerometerEvents.listen((event) {
      double force = (event.x.abs() + event.y.abs() + event.z.abs()) / 3;
      lastForce = force;

      if (force > 25) {
        handleAccident();
      }
    });
  }

  // =============================
  // UI
  // =============================
  void showSnack(String msg) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1420),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Smart Accident Assistant",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _feature(Icons.security, "يفتح تلقائيًا عند التصادم"),
            _feature(Icons.camera_alt, "يسجل فيديو تلقائي"),
            _feature(Icons.my_location, "يحفظ الموقع لحظة الحادث"),
            _feature(Icons.cloud_upload, "يرفع الفيديو للسيرفر"),
            _feature(Icons.warning_amber_rounded, "يرسل إشعار Firebase"),
            _feature(Icons.note_alt, "يحفظ في MongoDB"),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: activateAssistant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text("تفعيل النظام",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _feature(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(children: [
          Icon(i, color: Colors.redAccent, size: 30),
          const SizedBox(width: 15),
          Text(t, style: GoogleFonts.cairo(color: Colors.white, fontSize: 18))
        ]),
      );
}
