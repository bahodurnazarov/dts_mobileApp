import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'add_card.dart';
import 'app_bar.dart';
import 'car_card.dart';
import 'info_card.dart';

class GarageTab extends StatefulWidget {
  @override
  _GarageTabState createState() => _GarageTabState();
}

class _GarageTabState extends State<GarageTab> {
  List<Map<String, dynamic>> carData = [];

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  // Function to fetch car data from API
  Future<void> _fetchCars() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://10.10.25.239:8088/api/v1/transport/?page=0&size=30&sort=id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Include the token here
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print("1");
      setState(() {
        carData = List<Map<String, dynamic>>.from(data['content']);
      });
    } else {
      // Handle error if the request fails
      throw Exception('Failed to load car data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        foregroundColor: Colors.black,
        title: AppBarContent(),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Add functionality for settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCars, // Call the function when pulled down
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Ensure scrolling even when content is less
          child: Column(
            children: [
              // Car Cards with a sliding effect
              SizedBox(
                height: 250,
                child: carData.isEmpty
                    ? AddCarCard(
                  onAddCar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCarPage(),
                      ),
                    );
                  },
                )
                    : PageView.builder(
                  itemCount: carData.length + 1, // Add 1 for the AddCarCard
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    if (index < carData.length) {
                      // Regular CarCard
                      return CarCard(
                        carData: carData[index],
                        flag: 'assets/tajikistan_flag.jpg',
                      );
                    } else {
                      // AddCarCard
                      return AddCarCard(
                        onAddCar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCarPage(),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              // Info Cards Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: InfoCard(
                            title: 'Штрафы',
                            icon: Icons.gavel,
                            subtitle: '3 штрафы',
                            duration: '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoCard(
                          title: 'Тонировка',
                          icon: Icons.tune,
                          subtitle: 'Срок: 1 год',
                          duration: '12 месяцев',
                        ),
                        InfoCard(
                          title: 'Тех. осмотр',
                          icon: Icons.build,
                          subtitle: 'Годен до 2024',
                          duration: '1 год',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoCard(
                          title: 'Доверенность',
                          icon: Icons.assignment,
                          subtitle: 'На 1 год',
                          duration: '12 месяцев',
                        ),
                        InfoCard(
                          title: 'Страховка',
                          icon: Icons.security,
                          subtitle: 'Продлена до 2025',
                          duration: '12 месяцев',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InfoCard(
                          title: 'Газ',
                          icon: Icons.local_gas_station,
                          subtitle: 'Заправка через месяц',
                          duration: '30 дней',
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
