import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianChatScreen extends StatelessWidget {
  final String chatId;
  final String technicianId;

  const TechnicianChatScreen({
    super.key,
    required this.chatId,
    required this.technicianId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Text(
          "Chat ID: $chatId\nTechnician: $technicianId",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 16),
        ),
      ),
    );
  }
}
