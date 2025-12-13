import 'dart:io';
import 'package:camera/camera.dart';
// ignore: unused_import
import 'package:path_provider/path_provider.dart';

class VideoService {
  static Future<File> recordVideo({int durationSeconds = 10}) async {
    final cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.medium);

    await controller.initialize();
    await controller.startVideoRecording();

    await Future.delayed(Duration(seconds: durationSeconds));

    final XFile file = await controller.stopVideoRecording();
    return File(file.path);
  }
}
