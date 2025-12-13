import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccidentListScreen extends StatefulWidget {
  const AccidentListScreen({super.key});

  @override
  State<AccidentListScreen> createState() => _AccidentListScreenState();
}

class _AccidentListScreenState extends State<AccidentListScreen> {
  List accidents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAccidents();
  }

  Future<void> loadAccidents() async {
    final url = Uri.parse("http://192.168.1.11:5001/api/accidents");

    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        accidents = jsonDecode(res.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل الحوادث"),
        backgroundColor: Colors.redAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: accidents.length,
              itemBuilder: (context, i) {
                final a = accidents[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("حادث بتاريخ: ${a["date"]}"),
                    subtitle: Text("القوة: ${a["force"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccidentDetails(accident: a),
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

class AccidentDetails extends StatelessWidget {
  final Map accident;
  const AccidentDetails({super.key, required this.accident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الحادث"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📅 التاريخ: ${accident["date"]}",
                style: const TextStyle(fontSize: 18)),
            Text("📍 الموقع: ${accident["lat"]}, ${accident["lng"]}",
                style: const TextStyle(fontSize: 18)),
            Text("💥 قوة الصدمة: ${accident["force"]}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("🎥 تشغيل الفيديو"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("📄 فتح التقرير PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
