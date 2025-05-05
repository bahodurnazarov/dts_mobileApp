import 'package:dts/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../config/config.dart';
import '../../../config/globals.dart';
import '../../auth/businessPage.dart';
import '../../auth/refresh_token.dart';
import '../profile_tab.dart';
import 'individualEntrepreneur_register.dart';
import 'individual_register.dart';
import 'legalEntity_register.dart';

class UserTypeHandler extends StatefulWidget {
  final String apiUrl;
  final int userType;


  UserTypeHandler(this.apiUrl, this.userType);

  @override
  _UserTypeHandlerPageState createState() => _UserTypeHandlerPageState();
}

class _UserTypeHandlerPageState extends State<UserTypeHandler> {
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
        }

      } else if (response.statusCode == 404) {
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
      } else if (response.statusCode == 401) {
        await refreshAccessToken(context);
        return _checkUserType(url);
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
            globalIndividualName = userInfo?['individualName'] ?? userInfo?['name'] ?? 'Имя не указано';
            globalTIN = userInfo?['tin'] ?? 'Не указано';
            isLoading = false;
          });
        } else {
          throw Exception('Invalid content structure in the response.');
        }
      } else if (response.statusCode == 401) {
        await refreshAccessToken(context);
        return _fetchUserInfo(id);
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

    // If userInfo is available, show user information
    if (userInfo != null) {
      return WillPopScope(
        onWillPop: () async => true, // Prevent swipe back gesture
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Профиль',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: CupertinoColors.black,
              ),
            ),
          ),
          child: Center(
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
                      children: [
                        // User name
                        Text(
                          globalIndividualName,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                        ),
                        SizedBox(height: 15),

                        // User avatar
                        Icon(
                          CupertinoIcons.person_fill,
                          size: 90.0,
                          color: CupertinoColors.activeBlue,
                        ),
                        SizedBox(height: 20),

                        // User INN
                        Text(
                          'ИНН: $globalTIN',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(height: 10),

                        // Additional user information
                        Text(
                          'Страна: ${userInfo?['country']?['name'] ?? 'Не указано'}',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Город: ${userInfo?['city']?['name'] ?? 'Не указано'}',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Область: ${userInfo?['district']?['name'] ?? 'Не указано'}',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Button card for switching account type
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HomePage(), // EDIT2
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_2_circlepath,
                            color: CupertinoColors.activeBlue,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Сменить тип аккаунта',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
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

    // If userInfo is not found or an error occurred, show error screen
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
                'Не удалось загрузить информациddddю.',
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
    );
  }



}
