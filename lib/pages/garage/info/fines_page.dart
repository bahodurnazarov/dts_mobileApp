import 'package:flutter/material.dart';

class FinesPage extends StatelessWidget {
  final List<Map<String, String>> fines = [
    {
      "title": "Превышение скорости",
      "amount": "500 TJS",
      "status": "Не оплачено",
      "deadline": "2024-12-31",
    },
    {
      "title": "Неправильная парковка",
      "amount": "300 TJS",
      "status": "Оплачено",
      "deadline": "2024-11-15",
    },
    {
      "title": "Проезд на красный свет",
      "amount": "700 TJS",
      "status": "Не оплачено",
      "deadline": "2025-01-10",
    },
  ];

  FinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Штрафы"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: fines.length,
          itemBuilder: (context, index) {
            final fine = fines[index];
            return FineCard(
              title: fine["title"]!,
              amount: fine["amount"]!,
              status: fine["status"]!,
              deadline: fine["deadline"]!,
            );
          },
        ),
      ),
    );
  }
}


class FineCard extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final String deadline;

  const FineCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.status,
    required this.deadline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Сумма: $amount",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == "Оплачено" ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: status == "Оплачено" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Крайний срок: $deadline",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
