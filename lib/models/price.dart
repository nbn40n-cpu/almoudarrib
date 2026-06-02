class PriceItem {
  final int? id;
  final String name; // درس خصوصي، درس تراكتور، إلخ
  final String category; // lesson أو exam
  final String vehicleType; // خصوصي، تراكتور، شحن، باص
  final double price;
  final DateTime createdAt;

  PriceItem({
    this.id,
    required this.name,
    required this.category,
    required this.vehicleType,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'vehicleType': vehicleType,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PriceItem.fromMap(Map<String, dynamic> map) {
    return PriceItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      vehicleType: map['vehicleType'],
      price: (map['price'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  PriceItem copyWith({
    int? id,
    String? name,
    String? category,
    String? vehicleType,
    double? price,
    DateTime? createdAt,
  }) {
    return PriceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}