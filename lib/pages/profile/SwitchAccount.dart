import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page.dart';

class SwitchAccountPage extends StatelessWidget {
  Future<List<Map<String, String>>> _fetchAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessions = prefs.getString('user_sessions');
    return sessions != null
        ? List<Map<String, String>>.from(json.decode(sessions))
        : [];
  }

  Future<void> _switchAccount(BuildContext context, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessions = prefs.getString('user_sessions');
    List<Map<String, String>> allSessions = sessions != null
        ? List<Map<String, String>>.from(json.decode(sessions))
        : [];

    Map<String, String>? selectedSession =
    allSessions.firstWhere((session) => session['userId'] == userId);

    if (selectedSession != null) {
      await prefs.setString('active_user', json.encode(selectedSession));

      // Optionally, refresh the app or navigate back
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выбрать аккаунт'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _fetchAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки аккаунтов.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Аккаунты не найдены.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final account = snapshot.data![index];
                return ListTile(
                  title: Text(account['userId'] ?? 'Unknown User'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _switchAccount(context, account['userId']!),
                );
              },
            );
          }
        },
      ),
    );
  }
}
