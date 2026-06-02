import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class AppDb {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  static Future<void> init() async {
    await database;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'almoudarrib.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // جدول السيارات
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        plateNumber TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // جدول الأسعار
    await db.execute('''
      CREATE TABLE prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        price REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // جدول الدروس والتستات
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        lessonType TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        price REAL NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
      )
    ''');

    // جدول الدفعات
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // إدراج الأسعار الافتراضية
    await _insertDefaultPrices(db);
  }

  static Future<void> _insertDefaultPrices(Database db) async {
    final prices = [
      // الدروس
      PriceItem(
        name: 'درس خصوصي',
        category: 'lesson',
        vehicleType: 'خصوصي',
        price: 25,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'درس تراكتور',
        category: 'lesson',
        vehicleType: 'تراكتور',
        price: 25,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'درس شحن',
        category: 'lesson',
        vehicleType: 'شحن',
        price: 30,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'درس باص',
        category: 'lesson',
        vehicleType: 'باص',
        price: 40,
        createdAt: DateTime.now(),
      ),
      // التستات
      PriceItem(
        name: 'اختبار خصوصي',
        category: 'exam',
        vehicleType: 'خصوصي',
        price: 25,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'اختبار تراكتور',
        category: 'exam',
        vehicleType: 'تراكتور',
        price: 25,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'اختبار شحن',
        category: 'exam',
        vehicleType: 'شحن',
        price: 30,
        createdAt: DateTime.now(),
      ),
      PriceItem(
        name: 'اختبار باص',
        category: 'exam',
        vehicleType: 'باص',
        price: 40,
        createdAt: DateTime.now(),
      ),
    ];

    for (final price in prices) {
      await db.insert('prices', price.toMap());
    }
  }

  // ========== VEHICLES ==========
  static Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return db.insert('vehicles', vehicle.toMap());
  }

  static Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final result = await db.query('vehicles', orderBy: 'createdAt DESC');
    return result.map((map) => Vehicle.fromMap(map)).toList();
  }

  static Future<Vehicle?> getVehicleById(int id) async {
    final db = await database;
    final result = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Vehicle.fromMap(result.first);
  }

  static Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return db.update('vehicles', vehicle.toMap(), where: 'id = ?', whereArgs: [vehicle.id]);
  }

  static Future<int> deleteVehicle(int id) async {
    final db = await database;
    return db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // ========== PRICES ==========
  static Future<List<PriceItem>> getPrices() async {
    final db = await database;
    final result = await db.query('prices', orderBy: 'vehicleType ASC, category ASC');
    return result.map((map) => PriceItem.fromMap(map)).toList();
  }

  static Future<int> updatePrice(PriceItem price) async {
    final db = await database;
    return db.update('prices', price.toMap(), where: 'id = ?', whereArgs: [price.id]);
  }

  static Future<int> insertPrice(PriceItem price) async {
    final db = await database;
    return db.insert('prices', price.toMap());
  }

  static Future<int> deletePrice(int id) async {
    final db = await database;
    return db.delete('prices', where: 'id = ?', whereArgs: [id]);
  }

  // ========== LESSONS ==========
  static Future<int> insertLesson(Lesson lesson) async {
    final db = await database;
    return db.insert('lessons', lesson.toMap());
  }

  static Future<List<Lesson>> getLessons() async {
    final db = await database;
    final result = await db.query('lessons', orderBy: 'dateTime DESC');
    return result.map((map) => Lesson.fromMap(map)).toList();
  }

  static Future<List<Lesson>> getLessonsByMonth(int month, int year) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
    
    final result = await db.query(
      'lessons',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    return result.map((map) => Lesson.fromMap(map)).toList();
  }

  static Future<int> deleteLesson(int id) async {
    final db = await database;
    return db.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  // ========== PAYMENTS ==========
  static Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return db.insert('payments', payment.toMap());
  }

  static Future<List<Payment>> getPayments() async {
    final db = await database;
    final result = await db.query('payments', orderBy: 'dateTime DESC');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  static Future<List<Payment>> getPaymentsByMonth(int month, int year) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
    
    final result = await db.query(
      'payments',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  static Future<int> deletePayment(int id) async {
    final db = await database;
    return db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }
}
