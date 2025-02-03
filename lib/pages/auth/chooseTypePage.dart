import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import 'handle_userType.dart';

class ChooseTypePage extends StatelessWidget {
  final List<Map<String, String>> userTypes = [
    {
      "id": "1",
      "name": "Физическое лицо",
      "description": "Для физических лиц, которые хотят воспользоваться услугами без регистрации компании.",
    },
    {
      "id": "2",
      "name": "Юридическое лицо",
      "description": "Идеально подходит для регистрации компаний и организаций.",
    },
    {
      "id": "3",
      "name": "Индивидуальный предприниматель",
      "description": "Для самостоятельных предпринимателей, работающих без сотрудников.",
    },
  ];

  Future<void> _saveUserTypeAndNavigate(int userType, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_type', userType);

      Widget nextPage;

      // Navigate to the appropriate page based on user type
      switch (userType) {
        case 1:
          nextPage = UserTypeHandlerPage('$apiUrl/individual/check/', userType);
          break;
        case 2:
          nextPage = UserTypeHandlerPage('$apiUrl/company/check/', userType);
          break;
        case 3:
          nextPage = UserTypeHandlerPage('$apiUrl/entrepreneur/check/', userType);
          break;
        default:
          throw Exception("Invalid user type");
      }

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => nextPage),
      );
    } catch (e) {
      print('Error saving user type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: CupertinoPageScaffold(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F9FC), // Light background
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Выберите ваш тип',
                      style: TextStyle(
                        fontSize: 26,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A), // Neutral gray
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 80),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: userTypes.length,
                        itemBuilder: (context, index) {
                          final type = userTypes[index];
                          final int typeId = int.parse(type['id']!);
                          return GestureDetector(
                            onTap: () => _saveUserTypeAndNavigate(typeId, context),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Color(0xFFD1E8FF), // Light blue
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFF4A90E2), // Blue icon
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          type['name']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A4A4A), // Neutral gray
                                            decoration: TextDecoration.none, // Remove underline
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          type['description']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF7B8A99), // Subtle gray
                                            height: 1.5,
                                            decoration: TextDecoration.none, // Remove underline
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
