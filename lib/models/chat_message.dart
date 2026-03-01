class ChatMessage {
  final String localId;
  String? id;
  final String senderType; // user | technician
  final String text;
  final DateTime createdAt;
  String status; // sending | sent | failed
  final DateTime? readByTechnicianAt;

  ChatMessage({
    required this.localId,
    required this.senderType,
    required this.text,
    required this.createdAt,
    required this.status,
    this.id,
    this.readByTechnicianAt,
  });

  static DateTime _parse(dynamic v) {
    if (v == null) return DateTime.now();
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory ChatMessage.fromServer(Map<String, dynamic> m) {
    return ChatMessage(
      localId: (m["clientTempId"] ?? m["_id"] ?? DateTime.now().toString())
          .toString(),
      id: m["_id"]?.toString(),
      senderType: (m["senderType"] ?? "system").toString(),
      text: (m["text"] ?? "").toString(),
      createdAt: _parse(m["createdAt"]),
      status: "sent",
      readByTechnicianAt: m["readByTechnicianAt"] != null
          ? _parse(m["readByTechnicianAt"])
          : null,
    );
  }
}
