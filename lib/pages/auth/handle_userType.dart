import 'package:DTS/pages/auth/refresh_token.dart';
import 'package:DTS/pages/profile/profile_tab.dart';
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

class UserTypeHandlerPage extends StatefulWidget {
  final String apiUrl;
  final int userType;


  UserTypeHandlerPage(this.apiUrl, this.userType);

  @override
  _UserTypeHandlerPageState createState() => _UserTypeHandlerPageState();
}

class _UserTypeHandlerPageState extends State<UserTypeHandlerPage> {
  
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['content'] != null) {
          await _fetchUserInfo(data['content']);
        } else {
          // Use switch-case to navigate based on userType
          switch (widget.userType) {
            case 1:
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => IndividualPage(registrationType: 1),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => LegalRegistrationPage(registrationType: 2),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => EnterpreneurRegistrationPage(registrationType: 3),
                ),
              );
              break;
            default:
              throw Exception('Invalid user type');
          }
        }
      } else if (response.statusCode == 401) {
        await refreshAccessToken(context);
        return _checkUserType(url);
        _showUnauthorizedError();
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


  Future<void> _fetchUserInfo(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token is missing or invalid.');
      }

      // Determine the URL based on the global `userType`
      String endpoint;
      switch (widget.userType) {
        case 1:
          endpoint = '$apiUrl/individual/$id';
          break;
        case 2:
          endpoint = '$apiUrl/company/$id';
          break;
        case 3:
          endpoint = '$apiUrl/entrepreneur/$id';
          break;
        default:
          throw Exception('Invalid user type');
      }

      final response = await http.get(
        Uri.parse(endpoint),
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
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('An error occurred while fetching user info.');
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
    // Show loading screen if data is still being fetched
    if (isLoading) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Проверка пользователя',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: CupertinoColors.black,
            ),
          ),
        ),
        child: Center(
          child: CupertinoActivityIndicator(radius: 18),
        ),
      );
    }

    // If userInfo is available, show user information with animation
    if (userInfo != null) {
      Future.delayed(Duration(milliseconds: 2300), () {
        if (mounted) { // Check if the widget is still part of the tree
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false, // Removes all previous routes
          );
        }
      });





      return WillPopScope(
        onWillPop: () async => false, // Prevent swipe back gesture
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: Center(
            child: FadeTransition(
              opacity: AlwaysStoppedAnimation(1.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(seconds: 1),
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: Text(
                                  'Добро пожаловать',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(seconds: 1),
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: Text(
                                  '${userInfo?['individualName'] ?? userInfo?['name'] ?? 'Имя не указано'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 15),
                          AnimatedScale(
                            scale: 1.1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Icon(
                              CupertinoIcons.person_fill,
                              size: 90.0,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          SizedBox(height: 20),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(seconds: 1),
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: Text(
                                  'ИНН: ${userInfo!['tin'] ?? 'Не указано'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    decoration: TextDecoration.none,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              );
                            },
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

    // If userInfo is not found or an error occurred, show error screen with animation
    return WillPopScope(
      onWillPop: () async => false, // Prevent swipe back gesture
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
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
            duration: Duration(seconds: 1),
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle_fill,
                      size: 90.0,
                      color: CupertinoColors.destructiveRed,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Не удалось загрузить информацию.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.destructiveRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}
