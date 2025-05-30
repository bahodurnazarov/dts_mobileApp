import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PaymentsTab extends StatefulWidget {
  @override
  _PaymentsTabState createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  bool showPaidTransactions = true; // Toggle state for "Оплачено" and "Не оплачено"
  bool _darkMode = false; // Dark mode flag

  final List<Map<String, dynamic>> paidTransactions = [
    {'title': 'Штрафы', 'amount': 500.0, 'date': '20.11.2024'},
    {'title': 'Страховка', 'amount': 120.0, 'date': '15.11.2024'},
  ];

  final List<Map<String, dynamic>> pendingTransactions = [
    {'title': 'Технический осмотр', 'amount': 300.0, 'dueDate': '25.11.2024'},
    {'title': 'Штрафы', 'amount': 800.0, 'dueDate': '28.11.2024'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? Colors.black : Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Платежи',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black, // Set text color to black
          ),
        ),
        centerTitle: true,
        backgroundColor: _darkMode ? Colors.black : Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Toggle Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggleButton('Оплачено', true),
                _buildToggleButton('Не оплачено', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showPaidTransactions)
                    ...paidTransactions.map((transaction) =>
                        ModernTransactionCard(
                          title: transaction['title'],
                          amount: transaction['amount'],
                          date: transaction['date'],
                          isPaid: true,
                          darkMode: _darkMode,
                        )),
                  if (!showPaidTransactions)
                    ...pendingTransactions.map((transaction) =>
                        ModernTransactionCard(
                          title: transaction['title'],
                          amount: transaction['amount'],
                          date: transaction['dueDate'],
                          isPaid: false,
                          darkMode: _darkMode,
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isPaid) {
    final bool isActive = (isPaid && showPaidTransactions) ||
        (!isPaid && !showPaidTransactions);

    return GestureDetector(
      onTap: () {
        setState(() {
          showPaidTransactions = isPaid;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(32),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              color: isActive ? Colors.white : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernTransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final bool isPaid;
  final bool darkMode;

  const ModernTransactionCard({
    required this.title,
    required this.amount,
    required this.date,
    required this.isPaid,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: isPaid ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isPaid ? Icons.check_circle : Icons.schedule,
            color: isPaid ? Colors.green : Colors.red,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          isPaid ? 'Оплачено: $date' : 'Срок: $date',
          style: TextStyle(
            fontSize: 14,
            color: darkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPaid ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
