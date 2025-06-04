import 'package:dts/pages/auth/refresh_token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/config.dart';
import '../../config/globals.dart';
import '../home_page.dart';
import '../profile/registerProfile/individualEntrepreneur_register.dart';
import '../profile/registerProfile/individual_register.dart';
import '../profile/registerProfile/legalEntity_register.dart';
import 'login_page.dart';

class BusinessUserType extends StatefulWidget {
  final String apiUrl;
  final int userType;


  BusinessUserType(this.apiUrl, this.userType);

  @override
  _BusinessUserType createState() => _BusinessUserType();
}

class _BusinessUserType extends State<BusinessUserType> {
  
  bool isLoading = true;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    globalUserType = widget.userType;
    _checkUserType(widget.apiUrl);
  }



  Future<void> _checkUserType(String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      print(token);
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
          final content = json.decode(utf8.decode(response.bodyBytes)); // Decoding the response body to get content
          if (content['content'] != null && content['content'] is Map<String, dynamic>) {
            setState(() {
              userInfo = content['content']; // Ensure userInfo is a map, not a string
              // Now, safely extract the user details
              globalIndividualName = (userInfo?['individualName'] ?? userInfo?['shortName'] ?? userInfo?['name'] ?? 'Имя не указано').toString().trim();
              globalTIN = userInfo?['tin'] ?? 'Не указано';
              isLoading = false;
            });
          } else {
            throw Exception('Invalid content structure in the response.');
          }
        }
    } else if (response.statusCode == 404) {
       // Use switch-case to navigate based on userType\\
        switch (widget.userType) {
          case 2:
          // For case 2 (LegalRegistrationPage)
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => LegalRegistrationPage(registrationType: 2),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => EnterpreneurRegistrationPage(registrationType: 3),
              ),
            );
            break;
          default:
            throw Exception('Invalid user type');
        }
      } else if (response.statusCode == 401) {
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
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('An error occurred while checking the user type.');
    }
  }


  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showUnauthorizedError() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Unauthorized', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Your session has expired or you are not authorized. Please log in again.'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.pop(context);
            },
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
                              (userInfo?['individualName'] ?? userInfo?['shortName'] ?? userInfo?['name'] ?? 'Имя не указано').toString().trim(),
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
