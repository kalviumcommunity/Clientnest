import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Hub'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getPaymentsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final payments = snapshot.data!;
          
          double received = 0;
          double pending = 0;
          double overdue = 0;

          final now = DateTime.now();

          for (var p in payments) {
            final amt = (p['amount'] ?? 0).toDouble();
            if (p['status'] == 'paid') {
              received += amt;
            } else if (p['status'] == 'pending') {
              pending += amt;
              // Check overdue
              if (p['dueDate'] != null) {
                final due = p['dueDate'].toDate();
                if (due.isBefore(now)) overdue += amt;
              }
            }
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: _SummaryCard(title: 'Received', amount: received, color: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryCard(title: 'Pending', amount: pending, color: Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryCard(title: 'Overdue', amount: overdue, color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Text('Transaction List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (payments.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No transactions yet.'));
                    if (index >= payments.length) return null;

                    final p = payments[index];
                    final isPaid = p['status'] == 'paid';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        child: Icon(isPaid ? Icons.check : Icons.access_time, color: isPaid ? Colors.green : Colors.orange),
                      ),
                      title: Text(p['projectId'] ?? 'Unknown Project', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p['dueDate'] != null ? 'Due: ${(p['dueDate']).toDate().toString().split(' ')[0]}' : ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${(p['amount'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (p['status'] ?? 'unknown').toUpperCase(),
                              style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: payments.isEmpty ? 1 : payments.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text('\$${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
