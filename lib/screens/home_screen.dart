import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import 'screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المدرب'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0B6EF3),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // بطاقة الإحصائيات الرئيسية
                _buildStatsCard(context, appProvider),
                
                const SizedBox(height: 8),

                // الإدخال اليومي - زر كبير مميز
                _buildDailyInputButton(context),

                const SizedBox(height: 20),

                // القسم الثاني: الإدارة
                Text(
                  '⚙️ الإدارة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B6EF3),
                  ),
                ),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildMenuButton(
                      context,
                      'السيارات',
                      '🚗',
                      const Color(0xFF3B82F6),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                      ),
                    ),
                    _buildMenuButton(
                      context,
                      'الأسعار',
                      '💵',
                      const Color(0xFF10B981),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PricesScreen()),
                      ),
                    ),
                    _buildMenuButton(
                      context,
                      'الدفعات',
                      '💳',
                      const Color(0xFFF59E0B),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                      ),
                    ),
                    _buildMenuButton(
                      context,
                      'المساعد الذكي',
                      '🤖',
                      const Color(0xFF8B5CF6),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // القسم الثالث: التقارير
                Text(
                  '📊 التقارير',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B6EF3),
                  ),
                ),
                
                _buildReportButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AppProvider appProvider) {
    final now = DateTime.now();
    final total = appProvider.getTotalEarnings(now.month, now.year);
    final payments = appProvider.getTotalPayments(now.month, now.year);
    final remaining = appProvider.getRemainingBalance(now.month, now.year);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0B6EF3),
            const Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B6EF3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', 'ar').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'هذا الشهر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('الإجمالي', total, Colors.white),
              _buildStatColumn('المدفوع', payments, Colors.white70),
              _buildStatColumn('المتبقي', remaining, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, double value, Color color) {
    return Column(
      spacing: 4,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInputButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddLessonScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981),
              const Color(0xFF34D399),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          spacing: 8,
          children: [
            const Text(
              '➕',
              style: TextStyle(fontSize: 32),
            ),
            const Text(
              'الإدخال اليومي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'سجل درس أو اختبار جديد',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    String emoji,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButtons(BuildContext context) {
    final buttons = [
      {
        'label': '📊 التقرير الشامل',
        'color': const Color(0xFF0B6EF3),
        'screen': const ComprehensiveReportScreen(),
      },
      {
        'label': '🚗 الخصوصي والشحن',
        'color': const Color(0xFFF59E0B),
        'screen': const PrivateAndTruckReportScreen(),
      },
      {
        'label': '🚜 تقرير الفئات',
        'color': const Color(0xFF8B5CF6),
        'screen': const CategoryReportScreen(),
      },
    ];

    return Column(
      spacing: 10,
      children: buttons.map((button) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => button['screen'] as Widget),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (button['color'] as Color),
                  (button['color'] as Color).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (button['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                button['label'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
