import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/config.dart';
import '../../config/globals.dart';
import '../home_page.dart';
import '../profile/registerProfile/individual_register.dart';

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
            builder: (context) => IndividualPage(registrationType: 1),
          ),
        );
      } else if (response.statusCode == 401) {
        _showUnauthorizedError();
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

  void _showUnauthorizedError() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unauthorized', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Your session has expired or you are not authorized. Please log in again.'),
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
        navigationBar: const CupertinoNavigationBar(
          middle: Text(
            'Проверка пользователя',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: CupertinoColors.black,
            ),
          ),
        ),
        child: const Center(child: CupertinoActivityIndicator(radius: 18)),
      );
    }

    if (userInfo != null) {
      Future.delayed(const Duration(milliseconds: 2300), () {
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
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: Center(
            child: FadeTransition(
              opacity: const AlwaysStoppedAnimation(1.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.2),
                            blurRadius: 25.0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(seconds: 1),
                            builder: (context, opacity, child) => Opacity(
                              opacity: opacity,
                              child: const Text(
                                'Добро пожаловать',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(seconds: 1),
                            builder: (context, opacity, child) => Opacity(
                              opacity: opacity,
                              child: Text(
                                userInfo?['individualName'] ?? userInfo?['name'] ?? 'Имя не указано',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const AnimatedScale(
                            scale: 1.1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Icon(
                              CupertinoIcons.person_fill,
                              size: 90.0,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(seconds: 1),
                            builder: (context, opacity, child) => Opacity(
                              opacity: opacity,
                              child: Text(
                                'ИНН: ${userInfo!['tin'] ?? 'Не указано'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.none,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: const CupertinoNavigationBar(
          middle: Text(
            'Ошибка',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: CupertinoColors.black,
            ),
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, opacity, child) => Opacity(
              opacity: opacity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    size: 90.0,
                    color: CupertinoColors.destructiveRed,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Не удалось загрузить информациюqqqq.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.destructiveRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}