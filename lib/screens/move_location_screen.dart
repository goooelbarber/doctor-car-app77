import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: use_key_in_widget_constructors
class MoveLocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اختيار الموقع", style: GoogleFonts.cairo()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("العودة للمنزل", style: GoogleFonts.cairo()),
            leading: const Icon(Icons.home),
            onTap: () => Navigator.pop(context, "Home"),
          ),
          ListTile(
            title: Text("الانتقال لمكان آخر", style: GoogleFonts.cairo()),
            leading: const Icon(Icons.location_pin),
            onTap: () => Navigator.pop(context, "Other"),
          ),
          ListTile(
            title: Text("النقل للورشة", style: GoogleFonts.cairo()),
            leading: const Icon(Icons.home_repair_service),
            onTap: () => Navigator.pop(context, "Workshop"),
          ),
        ],
      ),
    );
  }
}
