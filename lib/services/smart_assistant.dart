import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/services.dart';

class SmartAssistant {
  final AppProvider appProvider;
  final TextToSpeechService ttsService;

  SmartAssistant({
    required this.appProvider,
    required this.ttsService,
  });

  /// معالجة الأمر الموحدة
  Future<String> processCommand(String command) async {
    try {
      final lowerCommand = command.toLowerCase().trim();

      // تسجيل درس جديد
      if ((lowerCommand.contains('سجل') || lowerCommand.contains('أضيف')) &&
          lowerCommand.contains('درس')) {
        return await _addLesson(command);
      }

      // تسجيل اختبار
      if ((lowerCommand.contains('سجل') || lowerCommand.contains('أضيف')) &&
          (lowerCommand.contains('اختبار') || lowerCommand.contains('تست'))) {
        return await _addExam(command);
      }

      // إضافة دفعة
      if ((lowerCommand.contains('أضيف') || lowerCommand.contains('دفع')) &&
          lowerCommand.contains('دفعة')) {
        return await _addPayment(command);
      }

      // إضافة سيارة
      if ((lowerCommand.contains('أضيف') || lowerCommand.contains('سجل')) &&
          lowerCommand.contains('سيارة')) {
        return await _addVehicle(command);
      }

      // تعديل السعر
      if (lowerCommand.contains('عدل') && lowerCommand.contains('سعر')) {
        return await _editPrice(command);
      }

      // حذف درس
      if (lowerCommand.contains('احذف') && lowerCommand.contains('درس')) {
        return await _deleteLesson(command);
      }

      // حذف دفعة
      if (lowerCommand.contains('احذف') && lowerCommand.contains('دفعة')) {
        return await _deletePayment(command);
      }

      // الاستعلام عن الإيرادات
      if ((lowerCommand.contains('كم') || lowerCommand.contains('ما')) &&
          (lowerCommand.contains('إيراد') || lowerCommand.contains('دخل'))) {
        return _getEarnings();
      }

      // الاستعلام عن الدفعات
      if ((lowerCommand.contains('كم') || lowerCommand.contains('ما')) &&
          (lowerCommand.contains('دفع') || lowerCommand.contains('مدفوع'))) {
        return _getPayments();
      }

      // الاستعلام عن الرصيد
      if ((lowerCommand.contains('كم') || lowerCommand.contains('ما')) &&
          (lowerCommand.contains('متبقي') || lowerCommand.contains('رصيد'))) {
        return _getBalance();
      }

      // عرض السيارات
      if ((lowerCommand.contains('اعرض') || lowerCommand.contains('عرض')) &&
          lowerCommand.contains('سيارة')) {
        return _listVehicles();
      }

      // عرض الأسعار
      if ((lowerCommand.contains('اعرض') || lowerCommand.contains('عرض')) &&
          lowerCommand.contains('سعر')) {
        return _listPrices();
      }

      // عرض الدروس
      if ((lowerCommand.contains('اعرض') || lowerCommand.contains('عرض')) &&
          lowerCommand.contains('درس')) {
        return _listLessons();
      }

      return 'أعتذر، لم أفهم الأمر. جرب: "سجل درس"، "أضيف دفعة"، "كم الإيرادات؟"';
    } catch (e) {
      return 'حدث خطأ: $e';
    }
  }

  // ========== إضافة درس ==========
  Future<String> _addLesson(String command) async {
    try {
      final vehicles = appProvider.vehicles;
      if (vehicles.isEmpty) {
        return 'لا توجد سيارات مسجلة. أضيف سيارة أولاً.';
      }

      // استخراج البيانات من الأمر
      final vehicle = vehicles.first; // السيارة الأولى كافتراضي
      final amount = _extractNumber(command) ?? 0.0;

      final lesson = Lesson(
        vehicleId: vehicle.id!,
        lessonType: 'درس',
        vehicleType: vehicle.type,
        price: amount > 0 ? amount : _getPriceForVehicle(vehicle.type, 'lesson'),
        dateTime: DateTime.now(),
      );

      await appProvider.addLesson(lesson);
      return 'تم تسجيل درس جديد للسيارة ${vehicle.name} بنجاح ✅';
    } catch (e) {
      return 'خطأ في تسجيل الدرس: $e';
    }
  }

  // ========== إضافة اختبار ==========
  Future<String> _addExam(String command) async {
    try {
      final vehicles = appProvider.vehicles;
      if (vehicles.isEmpty) {
        return 'لا توجد سيارات مسجلة.';
      }

      final vehicle = vehicles.first;
      final amount = _extractNumber(command) ?? 0.0;

      final lesson = Lesson(
        vehicleId: vehicle.id!,
        lessonType: 'تست',
        vehicleType: vehicle.type,
        price: amount > 0 ? amount : _getPriceForVehicle(vehicle.type, 'exam'),
        dateTime: DateTime.now(),
      );

      await appProvider.addLesson(lesson);
      return 'تم تسجيل اختبار جديد للسيارة ${vehicle.name} بنجاح ✅';
    } catch (e) {
      return 'خطأ في تسجيل الاختبار: $e';
    }
  }

  // ========== إضافة دفعة ==========
  Future<String> _addPayment(String command) async {
    try {
      final amount = _extractNumber(command);
      if (amount == null || amount <= 0) {
        return 'الرجاء تحديد مبلغ صحيح. مثال: "أضيف دفعة 500"';
      }

      final payment = Payment(
        amount: amount,
        dateTime: DateTime.now(),
      );

      await appProvider.addPayment(payment);
      return 'تمت إضافة دفعة بمبلغ $amount بنجاح ✅';
    } catch (e) {
      return 'خطأ في إضافة الدفعة: $e';
    }
  }

  // ========== إضافة سيارة ==========
  Future<String> _addVehicle(String command) async {
    try {
      final vehicleType = _extractVehicleType(command) ?? 'خصوصي';
      final name = _extractName(command) ?? 'سيارة جديدة';
      final plateNumber = _extractPlateNumber(command) ?? 'غير محدد';

      final vehicle = Vehicle(
        name: name,
        plateNumber: plateNumber,
        type: vehicleType,
        notes: '',
        createdAt: DateTime.now(),
      );

      await appProvider.addVehicle(vehicle);
      return 'تمت إضافة السيارة $name ($vehicleType) بنجاح ✅';
    } catch (e) {
      return 'خطأ في إضافة السيارة: $e';
    }
  }

  // ========== تعديل السعر ==========
  Future<String> _editPrice(String command) async {
    try {
      final newPrice = _extractNumber(command);
      if (newPrice == null || newPrice <= 0) {
        return 'الرجاء تحديد سعر صحيح.';
      }

      // تحديث أول سعر (كافتراضي)
      if (appProvider.prices.isNotEmpty) {
        final price = appProvider.prices.first.copyWith(price: newPrice);
        await appProvider.updatePrice(price);
        return 'تم تحديث السعر إلى $newPrice بنجاح ✅';
      }

      return 'لا توجد أسعار لتحديثها.';
    } catch (e) {
      return 'خطأ في تعديل السعر: $e';
    }
  }

  // ========== حذف درس ==========
  Future<String> _deleteLesson(String command) async {
    try {
      if (appProvider.lessons.isNotEmpty) {
        final lesson = appProvider.lessons.first;
        await appProvider.deleteLesson(lesson.id!);
        return 'تم حذف الدرس بنجاح ✅';
      }
      return 'لا توجد دروس لحذفها.';
    } catch (e) {
      return 'خطأ في حذف الدرس: $e';
    }
  }

  // ========== حذف دفعة ==========
  Future<String> _deletePayment(String command) async {
    try {
      if (appProvider.payments.isNotEmpty) {
        final payment = appProvider.payments.first;
        await appProvider.deletePayment(payment.id!);
        return 'تم حذف الدفعة بنجاح ✅';
      }
      return 'لا توجد دفعات لحذفها.';
    } catch (e) {
      return 'خطأ في حذف الدفعة: $e';
    }
  }

  // ========== الاستعلامات ==========
  String _getEarnings() {
    final now = DateTime.now();
    final amount = appProvider.getTotalEarnings(now.month, now.year);
    return 'إجمالي الإيرادات هذا الشهر: $amount';
  }

  String _getPayments() {
    final now = DateTime.now();
    final amount = appProvider.getTotalPayments(now.month, now.year);
    return 'إجمالي الدفعات هذا الشهر: $amount';
  }

  String _getBalance() {
    final now = DateTime.now();
    final amount = appProvider.getRemainingBalance(now.month, now.year);
    return 'الرصيد المتبقي هذا الشهر: $amount';
  }

  String _listVehicles() {
    if (appProvider.vehicles.isEmpty) {
      return 'لا توجد سيارات مسجلة.';
    }
    final list = appProvider.vehicles
        .map((v) => '${v.name} - ${v.type} (${v.plateNumber})')
        .join('\n');
    return 'السيارات المسجلة:\n$list';
  }

  String _listPrices() {
    if (appProvider.prices.isEmpty) {
      return 'لا توجد أسعار.';
    }
    final list = appProvider.prices
        .map((p) => '${p.name}: ${p.price}')
        .join('\n');
    return 'الأسعار:\n$list';
  }

  String _listLessons() {
    if (appProvider.lessons.isEmpty) {
      return 'لا توجد دروس مسجلة.';
    }
    final list = appProvider.lessons.take(5)
        .map((l) => '${l.lessonType} - ${l.price}')
        .join('\n');
    return 'آخر الدروس:\n$list';
  }

  // ========== دوال مساعدة ==========
  double? _extractNumber(String text) {
    final regex = RegExp(r'\d+(?:\.\d+)?');
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(0)!) : null;
  }

  String? _extractVehicleType(String text) {
    final types = ['خصوصي', 'تراكتور', 'شحن', 'باص'];
    for (final type in types) {
      if (text.contains(type)) return type;
    }
    return null;
  }

  String? _extractName(String text) {
    // محاولة استخراج الاسم من الأمر
    if (text.contains('اسم')) {
      final parts = text.split('اسم');
      if (parts.length > 1) {
        return parts[1].trim().split(' ').first;
      }
    }
    return null;
  }

  String? _extractPlateNumber(String text) {
    // محاولة استخراج رقم اللوحة
    if (text.contains('لوحة')) {
      final regex = RegExp(r'\d+');
      final match = regex.firstMatch(text);
      return match?.group(0);
    }
    return null;
  }

  double _getPriceForVehicle(String vehicleType, String category) {
    final price = appProvider.prices.firstWhere(
      (p) => p.vehicleType == vehicleType && p.category == category,
      orElse: () => PriceItem(
        name: '',
        category: '',
        vehicleType: '',
        price: 25,
        createdAt: DateTime.now(),
      ),
    );
    return price.price;
  }
}
