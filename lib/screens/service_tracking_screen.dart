import 'package:flutter/material.dart';

class ServiceTrackingScreen extends StatelessWidget {
  const ServiceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الخدمة'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Text('شاشة تتبع الخدمة', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
