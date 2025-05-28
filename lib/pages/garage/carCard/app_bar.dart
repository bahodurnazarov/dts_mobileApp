import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../config/config.dart';
import '../../../config/globals.dart';
import '../../auth/businessPage.dart';
import '../../auth/login_page.dart';
import '../../auth/privateAccountPage.dart';
import '../../auth/refresh_token.dart';
import 'list_cards.dart';

class AppBarContent extends StatelessWidget {
  final String flag = 'assets/tajikistan_flag.jpg';

  // Function to fetch car data from API
  Future<List<Map<String, dynamic>>> _fetchCars(BuildContext context, {bool isRetry = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Validate token exists
    if (token == null) {
      // Handle no token scenario (redirect to login?)
      throw Exception('No authentication token available');
    }

    String baseApiUrl = '';
    print('AppBarContent globalUserId :' + globalUserId);

    switch (globalUserType) {
      case 1:
        baseApiUrl = '$apiUrl/individual/$globalUserId/transports?page=0&limit=30&sort=id';
        break;
      case 3:
        baseApiUrl = '$apiUrl/entrepreneur/transports?page=0&limit=30&sort=id';
        break;
      case 2:
        baseApiUrl = '$apiUrl/company/transports?page=0&limit=30&sort=id';
        break;
      case 0:
      // Handle account type selection
        final accountType = prefs.getString('accountType') ?? 'private';
        if (accountType == 'private') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PrivateAccountPage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BusinessPage()));
        }
        return []; // Return empty list since we're navigating away
      default:
        throw Exception('Invalid user type');
    }

    print(baseApiUrl);
    final response = await http.get(
      Uri.parse(baseApiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      return List<Map<String, dynamic>>.from(data['content']);
    }
    else if (response.statusCode == 401) {
      if (isRetry) {
        // If we already retried once, avoid infinite loop
        throw Exception('Failed to refresh token or token still invalid');
      }

      print('Access token expired. Refreshing...');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      // await refreshAccessToken(context);
      //
      // // Retry with fresh token
       return _fetchCars(context, isRetry: true);
    }
    else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      print('Error ${response.statusCode}: $errorData');
      throw Exception('Failed to load car data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            try {
              // Fetch car data
              List<Map<String, dynamic>> carData = await _fetchCars(context);

              // Navigate to the CardListPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardListPage(
                    carData: carData,
                    flag: flag,
                  ),
                ),
              );
            } catch (e) {
              print('Error fetching car data: $e');
              // Show an error message if needed
            }
          },
          child: Icon(Icons.menu, color: Colors.black), // Left icon
        ),
        Spacer(flex: 1), // Adds space between the icon and the text
        Text(
          '     DTS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Spacer(), // Adds space between the text and the right side
      ],
    );
  }
}
