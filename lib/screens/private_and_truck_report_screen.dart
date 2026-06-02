import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class PrivateAndTruckReportScreen extends StatefulWidget {
  const PrivateAndTruckReportScreen({super.key});

  @override
  State<PrivateAndTruckReportScreen> createState() => _PrivateAndTruckReportScreenState();
}

class _PrivateAndTruckReportScreenState extends State<PrivateAndTruckReportScreen> {
  late DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚗 تقرير الخصوصي والشحن')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final report = appProvider.getPrivateAndTruckReport(_selectedDate.month, _selectedDate.year);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // اختيار الشهر
                Card(
                  child: ListTile(
                    title: const Text('الشهر'),
                    subtitle: Text(DateFormat('MMMM yyyy', 'ar').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),

                // التفاصيل اليومية
                if (report.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد بيانات'),
                    ),
                  )
                else
                  ...report.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('EEEE d MMMM', 'ar').format(item['date']),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Chip(
                                  label: Text(item['vehicleType']),
                                  backgroundColor: item['vehicleType'] == 'خصوصي'
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['lessonType']),
                                Text(
                                  '${item['price'].toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
