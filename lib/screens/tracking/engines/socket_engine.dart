import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef DriverLocationCallback = void Function(LatLng newPos);
typedef OrderStatusCallback = void Function(String status, Map data);

class SocketEngine {
  IO.Socket? socket;

  /// الاتصال بالسيرفر
  void connect({
    required String baseUrl,
    required String orderId,
    required DriverLocationCallback onDriverUpdate,
    required OrderStatusCallback onStatusChange,
  }) {
    socket = IO.io(
      baseUrl,
      {
        "transports": ["websocket"],
        "autoConnect": true,
      },
    );

    socket!.onConnect((_) {
      socket!.emit("joinOrderRoom", orderId);
    });

    // تحديث موقع الفني
    socket!.on("driverLocationUpdate", (data) {
      final pos = LatLng(
        (data["lat"] as num).toDouble(),
        (data["lng"] as num).toDouble(),
      );
      onDriverUpdate(pos);
    });

    // تحديث حالة الطلب
    socket!.on("orderStatusUpdated", (data) {
      final status = data["status"];
      onStatusChange(status, data);
    });
  }

  // قطع الاتصال
  void dispose() {
    socket?.dispose();
  }
}
