import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_details_screen.dart'; // ← تأكد من الاسم الصحيح للمسار

class PreviousServicesScreen extends StatelessWidget {
  const PreviousServicesScreen({super.key});

  final List<Map<String, dynamic>> previousOrders = const [
    {
      "serviceName": "سحب سيارة",
      "date": "2025-01-10",
      "status": "completed",
      "price": 350,
      "serviceType": "tow",
      "lat": 30.05052,
      "lng": 31.23311,
    },
    {
      "serviceName": "بنزين طوارئ",
      "date": "2025-01-02",
      "status": "completed",
      "price": 150,
      "serviceType": "fuel",
      "lat": 30.0650,
      "lng": 31.2100,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("الخدمات السابقة", style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),

      body: ListView.builder(
        itemCount: previousOrders.length,
        itemBuilder: (context, index) {
          final order = previousOrders[index];

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.redAccent.withOpacity(0.15),
                child: const Icon(Icons.history, color: Colors.redAccent, size: 28),
              ),

              title: Text(
                order["serviceName"],
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "تاريخ: ${order['date']}",
                style: GoogleFonts.cairo(color: Colors.grey.shade700),
              ),

              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
