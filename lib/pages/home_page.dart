import 'package:DTS/pages/profile/profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'directory/directory_tab.dart';
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
    return CupertinoTabScaffold(
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
            icon: Icon(CupertinoIcons.profile_circled),
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
    );
  }
}
