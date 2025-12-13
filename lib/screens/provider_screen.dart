import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final services = provider["services"];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(provider["name"], style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.redAccent.shade100,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            provider["name"],
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Text(
                "${provider['rating']}",
                style: GoogleFonts.cairo(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];
                return ListTile(
                  leading: Icon(s["icon"], color: Colors.redAccent),
                  title: Text(s["name"], style: GoogleFonts.cairo()),
                  trailing: Text(
                    "${s['price']} جنيه",
                    style: GoogleFonts.cairo(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
