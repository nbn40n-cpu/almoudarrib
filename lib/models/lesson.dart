class Lesson {
  final int? id;
  final int vehicleId;
  final String lessonType; // درس أو تست
  final String vehicleType; // خصوصي، تراكتور، شحن، باص
  final double price;
  final DateTime dateTime;
  final String? notes;

  Lesson({
    this.id,
    required this.vehicleId,
    required this.lessonType,
    required this.vehicleType,
    required this.price,
    required this.dateTime,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'lessonType': lessonType,
      'vehicleType': vehicleType,
      'price': price,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      vehicleId: map['vehicleId'],
      lessonType: map['lessonType'],
      vehicleType: map['vehicleType'],
      price: (map['price'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
    );
  }

  Lesson copyWith({
    int? id,
    int? vehicleId,
    String? lessonType,
    String? vehicleType,
    double? price,
    DateTime? dateTime,
    String? notes,
  }) {
    return Lesson(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      lessonType: lessonType ?? this.lessonType,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
    );
  }
}