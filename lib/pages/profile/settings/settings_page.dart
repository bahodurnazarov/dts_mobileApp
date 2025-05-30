import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: CupertinoNavigationBar(
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.left_chevron,
              size: 26,
              color: Colors.black, // ← Back button color
            ),
          ),
          middle: Text(
            'Настройки',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: CupertinoColors.white,
          border: Border(
            bottom: BorderSide(color: CupertinoColors.inactiveGray, width: 0.5),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSettingCard(
            context,
            icon: CupertinoIcons.lock,
            title: 'Безопасность',
            onTap: () {
              print('Перейти к настройкам безопасности');
            },
          ),
          SizedBox(height: 16),
          _buildSettingCard(
            context,
            icon: CupertinoIcons.bell,
            title: 'Уведомления',
            onTap: () {
              print('Перейти к настройкам уведомлений');
            },
          ),
          SizedBox(height: 16),
          _buildSettingCard(
            context,
            icon: CupertinoIcons.globe,
            title: 'Язык',
            onTap: () {
              print('Перейти к настройкам языка');
            },
          ),
          SizedBox(height: 16),
          _buildSettingCard(
            context,
            icon: CupertinoIcons.info_circle,
            title: 'О приложении',
            onTap: () {
              print('Открыть информацию о приложении');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context,
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
                ),
              ),
            ),
            Icon(
              CupertinoIcons.right_chevron,
              color: CupertinoColors.inactiveGray,
            ),
          ],
        ),
      ),
    );
  }
}
