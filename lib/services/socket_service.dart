import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String orderId) {
    socket = IO.io(
      "http://192.168.1.10:5001",
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("🔌 Connected to server");
      socket.emit("joinOrderRoom", orderId);
    });
  }

  void onTechnicianLocation(Function(double, double) callback) {
    socket.on("technicianLocationUpdate", (data) {
      final lat = data["location"]["lat"];
      final lng = data["location"]["lng"];
      callback(lat, lng);
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
