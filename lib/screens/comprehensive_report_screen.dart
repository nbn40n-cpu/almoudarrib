import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../providers/app_provider.dart';

class ComprehensiveReportScreen extends StatefulWidget {
  const ComprehensiveReportScreen({super.key});

  @override
  State<ComprehensiveReportScreen> createState() => _ComprehensiveReportScreenState();
}

class _ComprehensiveReportScreenState extends State<ComprehensiveReportScreen> {
  late DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 التقرير الشامل'),
        elevation: 0,
        backgroundColor: const Color(0xFF0B6EF3),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(context),
            tooltip: 'طباعة',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final report = appProvider.getComprehensiveReport(_selectedDate.month, _selectedDate.year);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // اختيار الشهر
                Card(
                  elevation: 2,
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

                // الكشف (شكل احترافي)
                _buildInvoiceCard(
                  child: Column(
                    spacing: 20,
                    children: [
                      // الرأس
                      Column(
                        spacing: 8,
                        children: [
                          const Text(
                            'كشف حسابات',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B6EF3),
                            ),
                          ),
                          Text(
                            'شهر ${DateFormat('MMMM yyyy', 'ar').format(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[300], thickness: 2),

                      // الملخص الرئيسي
                      Column(
                        spacing: 12,
                        children: [
                          _buildReportRow(
                            'إجمالي الدروس',
                            '${report['totalLessons']}',
                            Colors.blue,
                          ),
                          _buildReportRow(
                            'إجمالي الاختبارات',
                            '${report['totalExams']}',
                            Colors.orange,
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          _buildReportRow(
                            'إجمالي الإيرادات',
                            '${(report['totalEarnings'] as double).toStringAsFixed(0)}',
                            Colors.green,
                            isBold: true,
                          ),
                          _buildReportRow(
                            'إجمالي الدفعات',
                            '${(report['totalPayments'] as double).toStringAsFixed(0)}',
                            Colors.red,
                            isBold: true,
                          ),
                          Container(
                            height: 2,
                            color: Color(0xFF0B6EF3),
                          ),
                          _buildReportRow(
                            'الرصيد المتبقي',
                            '${(report['remainingBalance'] as double).toStringAsFixed(0)}',
                            Color(0xFF0B6EF3),
                            isBold: true,
                            fontSize: 18,
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[300], thickness: 2),

                      // توزيع حسب النوع
                      Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'توزيع حسب نوع السيارة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          ...((report['vehicleBreakdown'] as Map<String, Map<String, int>>).entries.map(
                            (entry) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTypeStatItem(
                                        'الدروس',
                                        '${entry.value['lessons']}',
                                      ),
                                      _buildTypeStatItem(
                                        'الاختبارات',
                                        '${entry.value['exams']}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),

                      Divider(color: Colors.grey[300], thickness: 1),

                      // التاريخ
                      Text(
                        'التاريخ: ${DateFormat('dd/MM/yyyy', 'ar').format(DateTime.now())}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildReportRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: fontSize,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeStatItem(String label, String value) {
    return Column(
      spacing: 4,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B6EF3),
          ),
        ),
      ],
    );
  }

  void _printReport(BuildContext context) async {
    final appProvider = context.read<AppProvider>();
    final report = appProvider.getComprehensiveReport(_selectedDate.month, _selectedDate.year);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            spacing: 20,
            children: [
              pw.Text(
                'كشف حسابات',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'شهر ${DateFormat('MMMM yyyy', 'ar').format(_selectedDate)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('إجمالي الدروس: ${report['totalLessons']}'),
                  pw.Text('إجمالي الاختبارات: ${report['totalExams']}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الإيرادات: ${(report['totalEarnings'] as double).toStringAsFixed(0)}'),
                  pw.Text('الدفعات: ${(report['totalPayments'] as double).toStringAsFixed(0)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الرصيد المتبقي: ${(report['remainingBalance'] as double).toStringAsFixed(0)}'),
                ],
              ),
              pw.Text(
                'التاريخ: ${DateFormat('dd/MM/yyyy', 'ar').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onPrinter: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
