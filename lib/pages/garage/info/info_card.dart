import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'fines_page.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final String duration;

  const InfoCard({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,  // Adjust width for layout
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        elevation: 2,  // Enhanced shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),  // Slightly rounded corners
        ),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FinesPage()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.blueAccent.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                if (duration.isNotEmpty)
                  Text(
                    'Срок: $duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
