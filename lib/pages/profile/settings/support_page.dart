import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Поддержка',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.none, // No underline
          ),
        ),
        backgroundColor: CupertinoColors.white,
        border: Border(bottom: BorderSide(color: CupertinoColors.inactiveGray, width: 0.5)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Support Section
            _buildSupportCard(
              context,
              icon: CupertinoIcons.phone,
              title: 'Контактная информация',
              onTap: () {
                print('Перейти к контактной информации');
                // You can navigate to another page or show dialog here
              },
            ),
            SizedBox(height: 16),

            _buildSupportCard(
              context,
              icon: CupertinoIcons.chat_bubble,
              title: 'Чат с поддержкой',
              onTap: () {
                print('Перейти к чату с поддержкой');
                // You can navigate to a chat screen or show a dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Icon(
                icon,
                size: 28,
                color: CupertinoColors.activeBlue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  decoration: TextDecoration.none, // No underline
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
