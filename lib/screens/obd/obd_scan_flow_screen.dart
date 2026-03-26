import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/obd/obd_elm327_service.dart';

class ObdScanFlowScreen extends StatefulWidget {
  const ObdScanFlowScreen({super.key});

  @override
  State<ObdScanFlowScreen> createState() => _ObdScanFlowScreenState();
}

class _ObdScanFlowScreenState extends State<ObdScanFlowScreen> {
  final ObdElm327Service obd = ObdElm327Service();
  StreamSubscription<List<ScanResult>>? _scanSub;

  final Map<String, ScanResult> _results = {};

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    _results.clear();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final id = r.device.id.id;
        _results[id] = r;
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _connect(ScanResult r) async {
    try {
      await FlutterBluePlus.stopScan();
      await obd.connect(r.device);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ OBD Connected")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Connect failed: $e")),
      );
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    obd.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _results.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        title: const Text("OBD Scan (BLE)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startScan,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final r = list[i];
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : "Unknown device";
          return ListTile(
            title: Text(name),
            subtitle: Text(r.device.id.id),
            trailing: Text("RSSI ${r.rssi}"),
            onTap: () => _connect(r),
          );
        },
      ),
    );
  }
}
