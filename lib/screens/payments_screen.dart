import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدفعات')),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final now = DateTime.now();
          final monthPayments = appProvider.getPaymentsByMonth(now.month, now.year);
          final total = appProvider.getTotalPayments(now.month, now.year);

          return Column(
            children: [
              // ملخص الدفعات
              Card(
                margin: const EdgeInsets.all(12),
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('إجمالي الدفعات هذا الشهر'),
                      const SizedBox(height: 8),
                      Text(
                        '${total.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // قائمة الدفعات
              Expanded(
                child: monthPayments.isEmpty
                    ? const Center(child: Text('لا توجد دفعات'))
                    : ListView.builder(
                        itemCount: monthPayments.length,
                        itemBuilder: (context, index) {
                          final payment = monthPayments[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text('${payment.amount.toStringAsFixed(0)}'),
                              subtitle: Text(DateFormat('yyyy-MM-dd', 'ar').format(payment.dateTime)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => appProvider.deletePayment(payment.id!),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دفعة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ'),
            ),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                context.read<AppProvider>().addPayment(
                  Payment(
                    amount: amount,
                    dateTime: DateTime.now(),
                    notes: notesController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
