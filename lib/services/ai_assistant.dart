import 'package:flutter/material.dart';

class AIAssistant {
  static const String _systemPrompt = '''
أنت مساعد ذكي لتطبيق المدرب - محاسبة مدرب السواقة.
يمكنك فهم الأوامر العربية بشكل كامل وتنفيذها بدقة.

المهام التي يمكنك تنفيذها:
1. إضافة سيارة جديدة: "أضيف سيارة خصوصي باسم أحمد برقم لوحة ****"
2. تسجيل درس: "سجل درس محمد درس خصوصي اليوم"
3. تسجيل اختبار: "سجل اختبار فاطمة تراكتور"
4. إضافة دفعة: "أضيف دفعة 500 من محمد"
5. عرض التقارير: "أريد التقرير الشامل"، "عرض تقرير الخصوصي"
6. البحث والعرض: "اعرض كل الدروس لهذا الشهر"، "كم مجموع الإيرادات؟"

عند التعامل مع الأوامر:
- استخدم فهمًا طبيعيًا للعربية
- استخرج البيانات المطلوبة من السياق
- اسأل عن التفاصيل الناقصة إذا لزم الأمر
- كن مهذبًا وحاول مساعدة المستخدم بأفضل طريقة

ردودك يجب أن تكون واضحة ومختصرة.
''';

  /// تحليل الأمر واستخراج النية
  static CommandIntent analyzeCommand(String command) {
    final lowerCommand = command.toLowerCase();

    // تسجيل درس
    if (lowerCommand.contains('سجل') && lowerCommand.contains('درس')) {
      return CommandIntent(
        type: 'add_lesson',
        description: 'تسجيل درس جديد',
        confidence: 0.95,
      );
    }

    // تسجيل اختبار/تست
    if (lowerCommand.contains('سجل') && (lowerCommand.contains('اختبار') || lowerCommand.contains('تست'))) {
      return CommandIntent(
        type: 'add_exam',
        description: 'تسجيل اختبار جديد',
        confidence: 0.95,
      );
    }

    // إضافة سيارة
    if (lowerCommand.contains('أضيف') && (lowerCommand.contains('سيارة') || lowerCommand.contains('سيارتي'))) {
      return CommandIntent(
        type: 'add_vehicle',
        description: 'إضافة سيارة جديدة',
        confidence: 0.95,
      );
    }

    // إضافة دفعة
    if (lowerCommand.contains('أضيف') && lowerCommand.contains('دفعة')) {
      return CommandIntent(
        type: 'add_payment',
        description: 'إضافة دفعة جديدة',
        confidence: 0.95,
      );
    }

    // عرض التقارير
    if (lowerCommand.contains('تقرير')) {
      if (lowerCommand.contains('شامل')) {
        return CommandIntent(
          type: 'show_comprehensive_report',
          description: 'عرض التقرير الشامل',
          confidence: 0.95,
        );
      }
      if (lowerCommand.contains('خصوصي') || lowerCommand.contains('شحن')) {
        return CommandIntent(
          type: 'show_private_truck_report',
          description: 'عرض تقرير الخصوصي والشحن',
          confidence: 0.95,
        );
      }
      if (lowerCommand.contains('فئة')) {
        return CommandIntent(
          type: 'show_category_report',
          description: 'عرض تقرير الفئات',
          confidence: 0.95,
        );
      }
    }

    // استعلامات الأرصدة
    if (lowerCommand.contains('كم') || lowerCommand.contains('إجمالي')) {
      if (lowerCommand.contains('إيرادات') || lowerCommand.contains('دخل')) {
        return CommandIntent(
          type: 'get_earnings',
          description: 'الحصول على إجمالي الإيرادات',
          confidence: 0.9,
        );
      }
      if (lowerCommand.contains('دفع') || lowerCommand.contains('مدفوع')) {
        return CommandIntent(
          type: 'get_payments',
          description: 'الحصول على إجمالي الدفعات',
          confidence: 0.9,
        );
      }
      if (lowerCommand.contains('متبقي') || lowerCommand.contains('رصيد')) {
        return CommandIntent(
          type: 'get_balance',
          description: 'الحصول على الرصيد المتبقي',
          confidence: 0.9,
        );
      }
    }

    // البحث والعرض
    if (lowerCommand.contains('اعرض') || lowerCommand.contains('عرض')) {
      if (lowerCommand.contains('سيارة')) {
        return CommandIntent(
          type: 'list_vehicles',
          description: 'عرض قائمة السيارات',
          confidence: 0.9,
        );
      }
    }

    return CommandIntent(
      type: 'unknown',
      description: 'أعتذر، لم أستطع فهم الأمر',
      confidence: 0.0,
    );
  }

  /// استخراج الأسماء والأرقام من النص
  static Map<String, dynamic> extractEntities(String text) {
    final entities = <String, dynamic>{};

    // البحث عن الأرقام
    final numberRegex = RegExp(r'\d+(?:\.\d+)?');
    final numbers = numberRegex.allMatches(text);
    if (numbers.isNotEmpty) {
      entities['amount'] = double.tryParse(numbers.first.group(0)!);
    }

    // أنواع السيارات
    final vehicleTypes = ['خصوصي', 'تراكتور', 'شحن', 'باص'];
    for (final type in vehicleTypes) {
      if (text.contains(type)) {
        entities['vehicleType'] = type;
        break;
      }
    }

    // أنواع الدروس
    if (text.contains('درس')) {
      entities['lessonType'] = 'درس';
    } else if (text.contains('اختبار') || text.contains('تست')) {
      entities['lessonType'] = 'اختبار';
    }

    return entities;
  }

  /// إنشاء رسالة ترحيب
  static String getWelcomeMessage() {
    return '''
👋 مرحبًا بك في مساعد المدرب الذكي!

أنا هنا لمساعدتك في:
📋 تسجيل الدروس والاختبارات
🚗 إدارة السيارات
💰 متابعة الدفعات
📊 عرض التقارير

جرّب بعض الأوامر مثل:
- "سجل درس محمد خصوصي اليوم"
- "أضيف سيارة جديدة"
- "كم مجموع الإيرادات؟"
- "أريد التقرير الشامل"

كيف يمكنني مساعدتك؟
''';
  }
}

class CommandIntent {
  final String type;
  final String description;
  final double confidence;

  CommandIntent({
    required this.type,
    required this.description,
    required this.confidence,
  });
}
