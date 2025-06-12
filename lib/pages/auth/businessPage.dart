import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../profile/BusinessHomePage.dart';
import 'accountType.dart';
import 'businessUserType.dart';

class BusinessPage extends StatelessWidget {
  final List<Map<String, String>> userTypes = [
    {
      "id": "4",
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
      switch (userType) {
        case 4:
          nextPage = BusinessHomePage();
          break;
        case 2:
          nextPage = BusinessUserType('$apiUrl/company', userType);
          break;
        case 3:
          nextPage = BusinessUserType('$apiUrl/entrepreneur', userType);
          break;
        default:
          throw Exception("Invalid user type");
      }

      Navigator.push(
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
      onWillPop: () async {
        // Navigate back to AccountTypeSelection when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountTypeSelection()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFF6F9FC), // Light blue background
          iconTheme: IconThemeData(color: Colors.black), // This makes back arrow black
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to AccountTypeSelection
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountTypeSelection()),
              );
            },
          ),
          title: Text(
            'Выберите ваш тип',
            style: TextStyle(color: Colors.black), // Black text color
          ),
          elevation: 0, // Optional: removes shadow for flat design
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F9FC),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
              ListView.builder(
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
                                  backgroundColor: Color(0xFFD1E8FF),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF4A90E2),
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
                                          color: Color(0xFF4A4A4A),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        type['description']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF7B8A99),
                                          height: 1.5,
                                          decoration: TextDecoration.none,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}