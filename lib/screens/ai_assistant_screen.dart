import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../providers/app_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  late TextEditingController _commandController;
  late SpeechRecognitionService _speechService;
  late TextToSpeechService _ttsService;
  
  List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController();
    _speechService = SpeechRecognitionService();
    _ttsService = TextToSpeechService();
    
    // الرسالة الترحيبية
    _messages.add(ChatMessage(
      text: AIAssistant.getWelcomeMessage(),
      isBot: true,
      timestamp: DateTime.now(),
    ));
    
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    final available = await _speechService.initialize();
    if (!available) {
      _ttsService.speak('عذراً، خدمة الصوت غير متاحة على جهازك');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      
      await _speechService.startListening();
      
      // محاكاة الاستماع (في التطبيق الحقيقي ستحصل على النتيجة من Speech API)
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _isListening = false);
          final recognized = _speechService.lastRecognizedWords;
          if (recognized.isNotEmpty) {
            _commandController.text = recognized;
            _processCommand(recognized);
          }
        }
      });
    }
  }

  void _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _processCommand(String command) async {
    if (command.isEmpty) return;

    // إضافة رسالة المستخدم
    setState(() {
      _messages.add(ChatMessage(
        text: command,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _commandController.clear();
      _isProcessing = true;
    });

    // تحليل الأمر
    final intent = AIAssistant.analyzeCommand(command);
    final entities = AIAssistant.extractEntities(command);

    String responseText = '';
    
    switch (intent.type) {
      case 'add_lesson':
        responseText = 'تم تسجيل درس جديد بنجاح ✅';
        break;
      case 'add_exam':
        responseText = 'تم تسجيل اختبار جديد بنجاح ✅';
        break;
      case 'add_vehicle':
        responseText = 'تمت إضافة السيارة بنجاح ✅';
        break;
      case 'add_payment':
        responseText = 'تمت إضافة الدفعة بنجاح ✅';
        break;
      case 'show_comprehensive_report':
        responseText = 'جاري فتح التقرير الشامل...';
        break;
      case 'get_earnings':
        final appProvider = context.read<AppProvider>();
        final now = DateTime.now();
        final earnings = appProvider.getTotalEarnings(now.month, now.year);
        responseText = 'إجمالي الإيرادات هذا الشهر: $earnings';
        break;
      case 'unknown':
        responseText = 'أعتذر، لم أستطع فهم الأمر. جرب: "سجل درس" أو "كم الإيرادات؟"';
        break;
      default:
        responseText = intent.description;
    }

    // إضافة رسالة المساعد
    setState(() {
      _messages.add(ChatMessage(
        text: responseText,
        isBot: true,
        timestamp: DateTime.now(),
      ));
      _isProcessing = false;
    });

    // النطق برد المساعد
    _ttsService.speak(responseText);
  }

  @override
  void dispose() {
    _commandController.dispose();
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 مساعدك الذكي'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // رسائل المحادثة
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: message.isBot ? Colors.grey[200] : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isBot ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // حقل الإدخال
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    decoration: InputDecoration(
                      hintText: 'اكتب أمرك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      prefixIcon: Icon(
                        _isListening ? Icons.mic : Icons.keyboard,
                        color: _isListening ? Colors.red : Colors.grey,
                      ),
                    ),
                    onSubmitted: _processCommand,
                  ),
                ),
                // زر الميكروفون
                FloatingActionButton(
                  mini: true,
                  onPressed: _isListening ? _stopListening : _startListening,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                // زر الإرسال
                FloatingActionButton(
                  mini: true,
                  onPressed: _isProcessing ? null : () => _processCommand(_commandController.text),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}
