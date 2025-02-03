import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'login_page.dart';

bool _isLoggingOut = false; // Prevent multiple logouts

Future<void> refreshAccessToken(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      print('No refresh token found. Logging out.');
      _logoutUser(context);
      return;
    }

    final response = await http.post(
      Uri.parse('$authUrl/auth/refresh-token'),
      headers: {
        "Authorization": "Bearer $refreshToken",
        "accept": "*/*",
      },
    );

    print('Token refresh response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      await prefs.setString('auth_token', responseData['access_token']);
      await prefs.setString('refresh_token', responseData['refresh_token']);
      print('Access token refreshed successfully.');
    } else {
      print('Refresh failed. Status: ${response.statusCode}, Response: ${response.body}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  } catch (e) {
    print('Exception during token refresh: $e');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
    _logoutUser(context);
  }
}



void _logoutUser(BuildContext context) async {
  if (_isLoggingOut) {
    print('Already logging out, skipping duplicate call.');
    return; // Prevent multiple calls
  }
  _isLoggingOut = true;

  print('Logging out: Clearing tokens and redirecting to login.');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('refresh_token');

  print('Tokens cleared. Navigating to login page...');

  Future.delayed(Duration(milliseconds: 500), () {
    if (context.mounted) {
      print('Navigating to login...');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Removes all previous routes
      );
    } else {
      print('Context is not mounted, unable to navigate.');
    }
  });
}
