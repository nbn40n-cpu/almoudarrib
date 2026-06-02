import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  late FlutterTts _flutterTts;

  factory TextToSpeechService() {
    return _instance;
  }

  TextToSpeechService._internal() {
    _flutterTts = FlutterTts();
    _initializeTTS();
  }

  void _initializeTTS() async {
    // تعيين اللغة إلى العربية
    await _flutterTts.setLanguage('ar');
    
    // تعيين الصوت (بنت)
    await _flutterTts.setPitch(1.2); // صوت أعلى قليلاً
    
    // سرعة الكلام
    await _flutterTts.setSpeechRate(0.8);
  }

  /// تحويل النص إلى كلام
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('خطأ في النطق: $e');
    }
  }

  /// إيقاف الكلام
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('خطأ في إيقاف النطق: $e');
    }
  }

  /// إيقاف مؤقت
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('خطأ في إيقاف النطق مؤقتاً: $e');
    }
  }

  /// المتابعة
  Future<void> resume() async {
    try {
      await _flutterTts.speak('');
    } catch (e) {
      print('خطأ في المتابعة: $e');
    }
  }
}
