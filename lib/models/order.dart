enum OrderStatus { pending, inProgress, completed, cancelled }

class Order {
  final String id; // uuid
  final String serviceKey; // e.g. "roadside", "maintenance"
  final String title; // "خدمة الطريق"
  final DateTime createdAt;
  final DateTime? completedAt;
  final OrderStatus status;

  // ممكن تزود: price, carId, notes, location, attachments ...
  const Order({
    required this.id,
    required this.serviceKey,
    required this.title,
    required this.createdAt,
    this.completedAt,
    required this.status,
  });

  Order copyWith({
    DateTime? completedAt,
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      serviceKey: serviceKey,
      title: title,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }
}
