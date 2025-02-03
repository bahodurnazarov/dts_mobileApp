import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../config/config.dart';
import '../../../config/globals.dart';
import '../../auth/chooseTypePage.dart';
import '../../auth/refresh_token.dart';
import 'list_cards.dart';

class AppBarContent extends StatelessWidget {
  final String flag = 'assets/tajikistan_flag.jpg';

  // Function to fetch car data from API
  Future<List<Map<String, dynamic>>> _fetchCars(BuildContext context) async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String baseApiUrl = '';  // Initialize baseApiUrl with an empty string

    // Set the appropriate API URL based on the userType
    switch (globalUserType) {
      case 1:
        baseApiUrl = '$apiUrl/individual/$globalUserId/transports?page=0&limit=30&sort=id';
        break;
      case 3:
        baseApiUrl = '$apiUrl/entrepreneur/$globalUserId/transports?page=0&limit=30&sort=id';
        break;
      case 2:
        baseApiUrl = '$apiUrl/company/$globalUserId/transports?page=0&limit=30&sort=id';
        break;
      case 0:
      // If globalUserType = 0, navigate to ChooseTypePage
      // If globalUserType = 0, navigate to ChooseTypePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseTypePage(),
          ),
        );
      default:
        print("Invalid user type");
    }

    // Make the HTTP request to fetch car data
    final response = await http.get(
      Uri.parse(baseApiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decodedResponse = utf8.decode(response.bodyBytes);
    final data = jsonDecode(decodedResponse);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['content']);
    } else if (response.statusCode == 401) {
      print('Access token expired. Refreshing...');
      // Refresh the token
      await refreshAccessToken(context);

      // Retry the request after refreshing the token
      return _fetchCars(context);
    } else {
      print('Error ${response.statusCode}: ${data}');
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
