import 'package:flutter/material.dart';
import '../models/models.dart';
import '../storage/app_db.dart';

class AppProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  List<PriceItem> _prices = [];
  List<Lesson> _lessons = [];
  List<Payment> _payments = [];

  bool _isLoading = false;

  // Getters
  List<Vehicle> get vehicles => _vehicles;
  List<PriceItem> get prices => _prices;
  List<Lesson> get lessons => _lessons;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  // ========== INITIALIZATION ==========
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadVehicles(),
      _loadPrices(),
      _loadLessons(),
      _loadPayments(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // ========== VEHICLES ==========
  Future<void> _loadVehicles() async {
    _vehicles = await AppDb.getVehicles();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await AppDb.insertVehicle(vehicle);
    _vehicles.add(vehicle.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await AppDb.updateVehicle(vehicle);
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(int id) async {
    await AppDb.deleteVehicle(id);
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // ========== PRICES ==========
  Future<void> _loadPrices() async {
    _prices = await AppDb.getPrices();
  }

  Future<void> updatePrice(PriceItem price) async {
    await AppDb.updatePrice(price);
    final index = _prices.indexWhere((p) => p.id == price.id);
    if (index != -1) {
      _prices[index] = price;
      notifyListeners();
    }
  }

  Future<void> addPrice(PriceItem price) async {
    final id = await AppDb.insertPrice(price);
    _prices.add(price.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deletePrice(int id) async {
    await AppDb.deletePrice(id);
    _prices.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ========== LESSONS ==========
  Future<void> _loadLessons() async {
    _lessons = await AppDb.getLessons();
  }

  Future<void> addLesson(Lesson lesson) async {
    final id = await AppDb.insertLesson(lesson);
    _lessons.insert(0, lesson.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteLesson(int id) async {
    await AppDb.deleteLesson(id);
    _lessons.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // ========== PAYMENTS ==========
  Future<void> _loadPayments() async {
    _payments = await AppDb.getPayments();
  }

  Future<void> addPayment(Payment payment) async {
    final id = await AppDb.insertPayment(payment);
    _payments.insert(0, payment.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deletePayment(int id) async {
    await AppDb.deletePayment(id);
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ========== CALCULATIONS ==========
  double getTotalEarnings(int month, int year) {
    final monthLessons = _lessons.where((l) {
      return l.dateTime.month == month && l.dateTime.year == year;
    }).toList();
    return monthLessons.fold(0.0, (sum, lesson) => sum + lesson.price);
  }

  double getTotalPayments(int month, int year) {
    final monthPayments = _payments.where((p) {
      return p.dateTime.month == month && p.dateTime.year == year;
    }).toList();
    return monthPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double getRemainingBalance(int month, int year) {
    return getTotalEarnings(month, year) - getTotalPayments(month, year);
  }

  // ========== REPORT DATA ==========
  Map<String, dynamic> getComprehensiveReport(int month, int year) {
    final monthLessons = _lessons.where((l) {
      return l.dateTime.month == month && l.dateTime.year == year;
    }).toList();

    final lessonsCount = monthLessons.where((l) => l.lessonType == 'درس').length;
    final examsCount = monthLessons.where((l) => l.lessonType == 'تست').length;

    final vehicleTypes = <String, Map<String, int>>{};
    for (final lesson in monthLessons) {
      vehicleTypes.putIfAbsent(lesson.vehicleType, () => {'lessons': 0, 'exams': 0});
      if (lesson.lessonType == 'درس') {
        vehicleTypes[lesson.vehicleType]!['lessons'] = vehicleTypes[lesson.vehicleType]!['lessons']! + 1;
      } else {
        vehicleTypes[lesson.vehicleType]!['exams'] = vehicleTypes[lesson.vehicleType]!['exams']! + 1;
      }
    }

    return {
      'totalLessons': lessonsCount,
      'totalExams': examsCount,
      'vehicleBreakdown': vehicleTypes,
      'totalEarnings': getTotalEarnings(month, year),
      'totalPayments': getTotalPayments(month, year),
      'remainingBalance': getRemainingBalance(month, year),
    };
  }

  List<Map<String, dynamic>> getPrivateAndTruckReport(int month, int year) {
    final monthLessons = _lessons.where((l) {
      return l.dateTime.month == month && l.dateTime.year == year &&
          (l.vehicleType == 'خصوصي' || l.vehicleType == 'شحن');
    }).toList();

    final report = <Map<String, dynamic>>[];
    for (final lesson in monthLessons) {
      report.add({
        'date': lesson.dateTime,
        'vehicleType': lesson.vehicleType,
        'lessonType': lesson.lessonType,
        'price': lesson.price,
      });
    }
    return report;
  }

  Map<String, dynamic> getCategoryReport(int month, int year, String category) {
    final monthLessons = _lessons.where((l) {
      return l.dateTime.month == month && l.dateTime.year == year && l.vehicleType == category;
    }).toList();

    final lessonsCount = monthLessons.where((l) => l.lessonType == 'درس').length;
    final examsCount = monthLessons.where((l) => l.lessonType == 'تست').length;
    final total = monthLessons.fold(0.0, (sum, l) => sum + l.price);

    return {
      'category': category,
      'lessons': lessonsCount,
      'exams': examsCount,
      'total': total,
      'details': monthLessons,
    };
  }
}
