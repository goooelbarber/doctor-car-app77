import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import '../managers/favorites_manager.dart';
import 'favorites_manager.dart';
import 'service_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesManager>().favorites;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("المفضلة", style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
      body: fav.isEmpty
          ? Center(
              child: Text(
                "لا توجد خدمات في المفضلة",
                style: GoogleFonts.cairo(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: fav.length,
              itemBuilder: (_, i) {
                final s = fav[i];
                return ListTile(
                  leading: Icon(s["icon"], color: Colors.redAccent, size: 30),
                  title: Text(s["name"], style: GoogleFonts.cairo()),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailsScreen(service: s),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
