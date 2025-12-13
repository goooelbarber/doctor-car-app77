import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccidentSensorService {
  static final AccidentSensorService _instance =
      AccidentSensorService._internal();

  factory AccidentSensorService() => _instance;

  AccidentSensorService._internal();

  StreamSubscription? _accelerometerSub;
  bool _crashDetected = false;
  bool simulationMode = false;

  void startMonitoring(BuildContext context) {
    stopMonitoring();

    _accelerometerSub = accelerometerEvents.listen((event) {
      if (simulationMode) return;

      final gX = event.x / 9.81;
      final gY = event.y / 9.81;
      final gZ = event.z / 9.81;

      final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > 2.5 && !_crashDetected) {
        _crashDetected = true;
        _openAccidentScreen(context);
      }
    });
  }

  void triggerSimulation(BuildContext context) {
    _openAccidentScreen(context);
  }

  void _openAccidentScreen(BuildContext context) {
    Navigator.pushNamed(context, "/smart-accident");
  }

  void stopMonitoring() {
    _accelerometerSub?.cancel();
    _crashDetected = false;
  }
}
