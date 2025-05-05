import 'package:dts/pages/auth/businessUserType.dart';
import 'package:dts/pages/auth/privateAccountPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'businessPage.dart';

class AccountTypeSelection extends StatelessWidget {
  const AccountTypeSelection({Key? key}) : super(key: key);

  Future<void> _saveAccountType(BuildContext context, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountType', type);

    if (type == 'private') {
      print("Private account selected");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrivateAccountPage(),
        ),
      );
    } else if (type == 'business') {
      print("Business account selected");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BusinessPage()),
      );
    } else {
      print("Unknown account type: $type");
      // Handle unexpected account type here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAccountCard(
                context,
                title: "Бизнес-аккаунт",
                subtitle: "Для компаний и организаций и ИП",
                icon: Icons.business_center_rounded,
                color: Colors.blueAccent,
                onTap: () => _saveAccountType(context, 'business'),
              ),
              const SizedBox(height: 20),
              _buildAccountCard(
                context,
                title: "Личный Аккаунт",
                subtitle: "Для личного использования",
                icon: Icons.person_rounded,
                color: Colors.green,
                onTap: () => _saveAccountType(context, 'private'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Card UI Component
  Widget _buildAccountCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 28,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),

            // Wrap the Text Column with Expanded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevents text overflow
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevents text overflow
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
