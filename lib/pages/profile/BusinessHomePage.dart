import 'package:dts/config/globals.dart';
import 'package:dts/pages/garage/mechanic_page.dart';
import 'package:dts/pages/home_page.dart';
import 'package:dts/pages/profile/profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../directory/directory_tab.dart';
import '../navigator/MapScreen.dart';
import '../payments/payments_tab.dart';

class BusinessHomePage extends StatefulWidget {
  @override
  _BusinessHomePageState createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car),
              // label: 'Гараж',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.creditcard),
              // label: 'Оплаты',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map),
              // label: 'Навигатор',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book),
              // label: 'Справочник',
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                // onLongPress: () => _showSwitchAccountDialog(context),
                child: Icon(CupertinoIcons.profile_circled),
              ),
              // label: 'Профиль',
            ),
          ],
          activeColor: Colors.blue[600],
          backgroundColor: Colors.white,
        ),
        tabBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return MechanicPage(); // A custom tab for business garage
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
                globalUserType = 1; // Switch to private account
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
                globalUserType = 2; // Set globalUserType to 2 for business account
                _switchToBusinessAccount();
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => BusinessHomePage()), // Navigate to Business Home Page
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
                globalUserType = 3; // Switch to individual entrepreneur
                _switchToBusinessAccount();
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => BusinessHomePage()), // Navigate to Business Home Page
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

  /// Logic for switching to business account
  void _switchToBusinessAccount() {
    // Add your logic for switching to a business account here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переключено на бизнес аккаунт')),
    );
  }

  /// Logic for switching to private account
  void _switchToPrivateAccount() {
    // Add your logic for switching to a private account here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Переключено на личный аккаунт')),
    );
  }
}
