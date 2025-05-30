import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/config.dart';
import '../../config/globals.dart';
import '../home_page.dart';
import '../profile/registerProfile/individual_register.dart';
import 'accountType.dart';
import 'login_page.dart';

class PrivateAccountPage extends StatefulWidget {
  const PrivateAccountPage();

  @override
  _PrivateAccountPage createState() => _PrivateAccountPage();
}

class _PrivateAccountPage extends State<PrivateAccountPage> {
  bool isLoading = true;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    globalUserType = 1;
    _checkUserType('$apiUrl/individual/check/');
  }

  Future<void> _fetchUserInfo(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or invalid.');
      }
      print('ID '+ id);
      final response = await http.get(
        Uri.parse('$apiUrl/individual/$id'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['content'] != null && data['content'] is Map<String, dynamic>) {
          setState(() {
            userInfo = data['content'];
            globalUserId = id;
            globalIndividualName = userInfo?['individualName'] ?? userInfo?['name'] ?? 'Имя не указано';
            globalTIN = userInfo?['tin'] ?? 'Не указано';
            isLoading = false;
          });
        } else {
          throw Exception('Invalid content structure in the response.');
        }
      } else {
        throw Exception('Failed to fetch user info. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
      _showErrorDialog('An error occurred while fetching user info.');
    }
  }

  Future<void> _checkUserType(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or invalid.');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['content'] != null) {
          await _fetchUserInfo(data['content']);
        }
      } else if (response.statusCode == 404) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => IndividualPage(),
          ),
        );
      } else if (response.statusCode == 401) {
        //_showUnauthorizedError();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return;
      } else {
        throw Exception('Failed to check user type. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
      _showErrorDialog('An error occurred while checking the user type.');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.extraLightBackgroundGray, // Light background
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.extraLightBackgroundGray, // Matching light nav bar
          middle: Text(
            'Проверка пользователя',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
              decoration: TextDecoration.none, // Explicitly remove underline
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 18),
              const SizedBox(height: 20),
              Text(
                'Загрузка...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  decoration: TextDecoration.none, // No underline
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (userInfo != null) {
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
          );
        }
      });

      return WillPopScope(
        onWillPop: () async => false,
        child: CupertinoPageScaffold(
          backgroundColor: Colors.grey[50],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Modern white card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Добро пожаловать',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User info row
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.person_circle_fill,
                                size: 36,
                                color: Colors.blue[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userInfo?['individualName'] ?? userInfo?['name'] ?? 'Имя не указано',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ИНН: ${userInfo!['tin'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress indicator
                        SizedBox(
                          width: double.infinity,
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Перенаправляем...',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Error state
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.grey[50],
        navigationBar: const CupertinoNavigationBar(
          middle: Text(
            'Ошибка',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    size: 50,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Не удалось загрузить информацию',
                  style: TextStyle(
                    fontSize: 22,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте войти снова',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.red.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // Add retry logic
                    },
                    child: const Text(
                      'Попробовать снова',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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