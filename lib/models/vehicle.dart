class Vehicle {
  final int? id;
  final String name;
  final String plateNumber;
  final String type; // خصوصي، تراكتور، شحن، باص
  final String notes;
  final DateTime createdAt;

  Vehicle({
    this.id,
    required this.name,
    required this.plateNumber,
    required this.type,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'plateNumber': plateNumber,
      'type': type,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      plateNumber: map['plateNumber'],
      type: map['type'],
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Vehicle copyWith({
    int? id,
    String? name,
    String? plateNumber,
    String? type,
    String? notes,
    DateTime? createdAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      plateNumber: plateNumber ?? this.plateNumber,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}