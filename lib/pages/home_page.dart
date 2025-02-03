import 'package:DTS/config/globals.dart';
import 'package:DTS/pages/profile/profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'directory/directory_tab.dart';
import 'navigator/MapScreen.dart';
import 'navigator/navigator_tab.dart';
import 'payments/payments_tab.dart';
import 'garage/garage_tab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car),
              label: 'Гараж',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.creditcard),
              label: 'Оплаты',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map),
              label: 'Навигатор',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book),
              label: 'Справочник',
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onLongPress: () => _showSwitchAccountDialog(context),
                child: Icon(CupertinoIcons.profile_circled),
              ),
              label: 'Профиль',
            ),
          ],
          activeColor: Colors.blue[600],
          backgroundColor: Colors.white,
        ),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return GarageTab();
            case 1:
              return PaymentsTab();
            case 2:
              return NavigatorTab();
            case 3:
              return DirectoryTab();
            case 4:
              return ProfilePage();
            default:
              return Center(child: Text('Page not found'));
          }
        },
      ),
    );
  }

  /// Show account switch dialog or action sheet
  void _showSwitchAccountDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text(
            'Сменить аккаунт',
            style: TextStyle(color: CupertinoColors.systemBlue),
          ),
          message: const Text(
            'Выберите аккаунт для переключения:',
            style: TextStyle(color: CupertinoColors.systemBlue),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                globalUserType = 1; // Set globalUserType to 1 for 'Физическое лицо'
                _switchToPrivateAccount();
              },
              child: const Text(
                'Физическое лицо',
                style: TextStyle(color: CupertinoColors.systemBlue),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                globalUserType = 2; // Set globalUserType to 2 for 'Юридическое лицо'
                _switchToBusinessAccount();
                // Navigate to GarageTab
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text(
                'Юридическое лицо',
                style: TextStyle(color: CupertinoColors.systemBlue),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                globalUserType = 3; // Set globalUserType to 3 for 'Индивидуальный предприниматель'
                _switchToBusinessAccount();
                // Navigate to GarageTab
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => HomePage()),
                );
              },
              child: const Text(
                'Индивидуальный предприниматель',
                style: TextStyle(color: CupertinoColors.systemBlue),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Отмена',
              style: TextStyle(color: CupertinoColors.systemRed),
            ),
          ),
        );
      },
    );
  }

  /// Logic for switching to private account
  void _switchToPrivateAccount() {
    // Add your logic for switching to a private account here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переключено на личный аккаунт')),
    );
  }

  /// Logic for switching to business account
  void _switchToBusinessAccount() {
    // Add your logic for switching to a business account here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переключено на бизнес аккаунт')),
    );
  }
}
