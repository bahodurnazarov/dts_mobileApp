import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_page.dart';
import 'individualEntrepreneur_register.dart';
import 'legalEntity_register.dart';
import 'individual_register.dart';
import 'register_type.dart';
import 'settings_page.dart';  // Add the import for RegistrationPage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? selectedRegistrationType = null; // 1 for individual, 2 for legal entity, 3 for sole proprietor

// Callback function to handle registration type changes
  void _onRegistrationTypeChanged(int newType) {
    setState(() {
      selectedRegistrationType = newType;
    });

    // Navigate to the appropriate page based on the selected registration type
    if (selectedRegistrationType == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualPage(
              registrationType: newType
          ),
        ),
      );
    } else if (selectedRegistrationType == 2 ) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LegalRegistrationPage(
            registrationType: newType,
          ),
        ),
      );
    } else if  (selectedRegistrationType == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterpreneurRegistrationPage(
              registrationType: newType
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the custom RegistrationTypeSelector widget
              RegistrationTypeSelector(
                selectedRegistrationType: selectedRegistrationType,
                onValueChanged: _onRegistrationTypeChanged, // Pass the callback
              ),

              SizedBox(height: 12),

              // Settings Section
              Text(
                'Настройки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 12),
              _buildOptionTile(
                context,
                icon: CupertinoIcons.settings,
                color: CupertinoColors.activeBlue,
                title: 'Настройки',
                onTap: () {
                  // Navigate to Settings Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              _buildOptionTile(
                context,
                icon: CupertinoIcons.question_circle_fill,
                color: CupertinoColors.systemYellow,
                title: 'Часто задаваемые вопросы',
                onTap: () {
                  print('Перейти к ЧЗВ');
                },
              ),
              _buildOptionTile(
                context,
                icon: CupertinoIcons.chat_bubble_2_fill,
                color: CupertinoColors.systemGreen,
                title: 'Поддержка',
                onTap: () {
                  print('Перейти к Поддержке');
                },
              ),

              SizedBox(height: 32),

              // Logout Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CupertinoColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  ),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token');

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                    );
                  },
                  child: Text(
                    'Выйти',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            Spacer(),
            //Icon(CupertinoIcons.right_chevron, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }
}
