import 'package:dts/config/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/config.dart';
import '../auth/businessPage.dart';
import '../auth/login_page.dart';
import '../auth/privateAccountPage.dart';
import '../auth/refresh_token.dart';
import '../lessons/lessons_page.dart';
import '../licency/LicensePage.dart' as licency ;
import 'carCard/add_card.dart';
import 'carCard/app_bar.dart';
import 'carCard/car_card.dart';
import 'carCard/card.dart';
import 'info/info_card.dart';

class GarageTab extends StatefulWidget {
  @override
  _GarageTabState createState() => _GarageTabState();
}

class _GarageTabState extends State<GarageTab> {
  List<Map<String, dynamic>> carData = [];
  final PageController _pageController = PageController(viewportFraction: 0.95);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  // Function to fetch car data from API based on userType
  Future<void> _fetchCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String baseApiUrl = '';
    // Set the appropriate API URL based on the userType
    print("GarageTab globalUserId: $globalUserId");

    if (globalUserId == null) {
      // globalUserId is null, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }
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
      case 0: // EDIT2
      // Get the account type from SharedPreferences or widget parameter
        final String accountType = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('accountType') ?? 'private');

        await SharedPreferences.getInstance().then((prefs) =>
            prefs.setString('accountType', accountType));
        if (accountType == 'private') {
          print("Private account selected");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PrivateAccountPage(),
            ),
          );
        } else if (accountType == 'business') {
          print("Business account selected");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BusinessPage()),
          );
        }
        return; // Prevent further execution after navigation
    }

    try {
      final response = await http.get(
        Uri.parse(baseApiUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);

        final List<dynamic> content = data['content'] ?? [];

        setState(() {
          carData = content.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return;
          // await refreshAccessToken(context);
          // await _fetchCars();
      } else {
        setState(() {
          _errorMessage = 'Failed to load car data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
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
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCars,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildCarCardsSection(),
              SizedBox(height: 10),
              if (globalUserType == 2 || globalUserType == 3) _buildButtonsSection(),
              SizedBox(height: 6),
              _buildInfoCardsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarCardsSection() {
    return SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 230,
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
              itemCount: carData.length + 1,
              controller: _pageController,
              onPageChanged: (index) {
                _currentPageNotifier.value = index;
              },
              itemBuilder: (context, index) {
                if (index < carData.length) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: CarCard( // here is the error
                      carData: carData[index],
                      flag: 'assets/tajikistan_flag.jpg',
                    ),
                  );
                } else {
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
          SizedBox(height: 10),
          ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentPage, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  carData.length + 1,
                      (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: currentPage == index ? 16.0 : 8.0,
                    decoration: BoxDecoration(
                      color: currentPage == index ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
        physics: NeverScrollableScrollPhysics(), // Disables scrolling
        children: [
          _buildModernButton('Лицензия', Icons.book),
          _buildModernButton('Дозвол', Icons.assignment_turned_in),
          _buildModernButton('Сертификат', Icons.verified),
          _buildModernButton('e-TIR', Icons.local_shipping),
        ],
      ),
    );
  }

  _buildInfoCardsSection() {
    return IgnorePointer(
      ignoring: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Штрафы (Fines)
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

            // Тонировка (Tinting) & Тех. осмотр (Tech Inspection)
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

            // Доверенность (Proxy) & Страховка (Insurance)
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

            // Газ (Gas)
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
    );
  }


  Widget _buildModernButton(String title, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.blueAccent,
        shadowColor: Colors.blue.withOpacity(0.5),
        elevation: 5,
      ),
      onPressed: () {
        if (title == 'Сертификат') {  // Changed from 'Сертификата'
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LessonsPage()),
          );
        } else if (title == 'Лицензия') {  // Changed from 'Лицензии'
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => licency.LicensePage()),
          );
        } else {
          // Handle other buttons if needed
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}