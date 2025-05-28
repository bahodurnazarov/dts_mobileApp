import 'dart:convert';
import 'package:dts/pages/profile/profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';
import '../../auth/businessPage.dart';
import '../../auth/login_page.dart';
import '../../auth/refresh_token.dart';


class EnterpreneurRegistrationPage extends StatefulWidget {
  final int registrationType;


  EnterpreneurRegistrationPage({required this.registrationType});

  @override
  _EnterpreneurRegistrationPage createState() => _EnterpreneurRegistrationPage();
}

class _EnterpreneurRegistrationPage extends State<EnterpreneurRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController einController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController officeController = TextEditingController();
  final TextEditingController actualAddressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();


  bool _isNameFieldDisabled = true; // To manage the 'Название' field's editability
  String? _errorMessage; // To display errors if any

  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedActivityStatus;

  List<Map<String, String>> counties = [];
  List<Map<String, String>> cities = [];
  List<Map<String, String>> districts = [];
  List<Map<String, String>> activityStatuses = [];


  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {


    try {
      counties = await _fetchDropdownOptions('$apiUrl/country/?page=0&size=3000&sort=id');
      cities = await _fetchDropdownOptions('$apiUrl/city/?page=0&size=3000&sort=id');
      districts = await _fetchDropdownOptions('$apiUrl/district/?page=0&size=3000&sort=id');
      activityStatuses = await _fetchDropdownOptions('$apiUrl/activitystatus/?page=0&size=3000&sort=id');
      setState(() {});
    } catch (e) {
      print('Error loading dropdown data: $e');
    }
  }

  Future<List<Map<String, String>>> _fetchDropdownOptions(String url) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing');
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody)['content'] as List;
        return data.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name']?.toString() ?? 'N/A',
          };
        }).toList();
      } else if (response.statusCode == 401) {
        // await refreshAccessToken(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return _fetchDropdownOptions(url);
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dropdown options: $e');
      return [];
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error retrieving auth token: $e');
      return null;
    }
  }



  Future<void> _fetchNameFromInn(String inn) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = "Authentication token not found.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$apiUrl/inn/?inn=$inn'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedResponse);

      if (response.statusCode == 200) {
        // Successful response
        setState(() {
          nameController.text = data['fullName']?.toString() ?? "Unknown Name";
          countryController.text = "Таджикистан";
          einController.text = data['ein']?.toString() ?? "Unknown Name";
          _isNameFieldDisabled = true; // Disable the field after fetching
          _errorMessage = null; // Clear any previous errors
        });
      } else if (response.statusCode == 404) {
        // INN not found
        setState(() {
          nameController.text = "Не найдено"; // Display "Not Found" in Russian
          einController.text = "?"; // Display "Not Found" in Russian
          _isNameFieldDisabled = false; // Keep the field editable
          _errorMessage = null; // Clear errors if any
        });
      } else {
        // Other error statuses
        setState(() {
          _errorMessage =
          "Failed to fetch data. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => BusinessPage()),
                  (Route<dynamic> route) => false,
            );
          },
          child: Icon(
            CupertinoIcons.back,
            color: Colors.black,
          ),
        ),
        middle: Text(
          'Регистрация',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: CupertinoColors.white,
        border: Border(bottom: BorderSide(color: CupertinoColors.inactiveGray, width: 0.5)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Тип регистрации: ${_getRegistrationTypeString()}',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              // ),
              // SizedBox(height: 32),

              // Text fields for user input
              _buildInnField('ИНН', tinController, requiredField: true),
              _buildInnTextField('Название', nameController, requiredField: true),
              _buildInnTextField('ЕИН', einController),
              _buildTextField('Адрес', addressController),
              _buildTextField('Дом/Кв', officeController),
              _buildTextField('Текущий адрес', actualAddressController),
              _buildNumberField('Номер телефона', usernameController, requiredField: true),

              SizedBox(height: 32),

              // Dropdowns for registration

              _buildInnTextField('Страна', countryController),

              _buildDropdownWithSearch('Город', cities, selectedCity, (newValue) {
                setState(() {
                  selectedCity = newValue;
                });
              }),
              _buildDropdownWithSearch('Регион', districts, selectedDistrict, (newValue) {
                setState(() {
                  selectedDistrict = newValue;
                });
              }),
              _buildDropdownWithSearch('Статус', activityStatuses, selectedActivityStatus, (newValue) {
                setState(() {
                  selectedActivityStatus = newValue;
                });
              }),
              SizedBox(height: 32),

              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CupertinoColors.activeBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    _submitRegistration();
                  },
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInnField(String label, TextEditingController controller, {bool requiredField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // Set default color
            children: requiredField
                ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20),
              ),
            ]
                : [],
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Введите $label',
          placeholderStyle: TextStyle(
            color: Colors.black38, // Make placeholder text black
            fontSize: 14,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(fontSize: 16),
          keyboardType: TextInputType.number, // Restrict to number input
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.length >= 9) {
              // Call _fetchNameFromInn if the length exceeds 9
              _fetchNameFromInn(value);
            }
          },
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }

  Widget _buildInnTextField(String label, TextEditingController controller, {bool requiredField = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black), // Set default color
            children: requiredField
                ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20),
              ),
            ]
                : [],
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Введите $label',
          placeholderStyle: TextStyle(
            color: Colors.black38, // Make placeholder text black
            fontSize: 14,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(
            fontSize: 16,
            color: controller.text == 'Не найдено' ? Colors.red : Colors.black, // Check if text is 'Не найдено'
          ),
          readOnly: _isNameFieldDisabled, // Disable editing if the name is fetched
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }

  // TextField widget for user input
  Widget _buildTextField(String label, TextEditingController controller, {bool requiredField = false, bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: requiredField
                ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20),
              ),
            ]
                : [],
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Введите $label',
          placeholderStyle: TextStyle(
            color: Colors.black38, // Make placeholder text black
            fontSize: 14,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(fontSize: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
          enabled: isEnabled, // Enable or disable based on the value passed
        ),
        SizedBox(height: 6),
      ],
    );
  }

  // Number field widget
  Widget _buildNumberField(String label, TextEditingController controller, {bool requiredField = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: requiredField
                ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20),
              ),
            ]
                : [],
          ),
        ),
        SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: 'Введите $label',
          placeholderStyle: TextStyle(
            color: Colors.black38, // Make placeholder text black
            fontSize: 14,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(fontSize: 16),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
          onChanged: onChanged,
        ),
        SizedBox(height: 6),
      ],
    );
  }



  Widget _buildDropdownWithSearch(
      String label,
      List<Map<String, String>> options,
      String? selectedValue,
      Function(String?)? onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black, // changed from grey
          ),
        ),
        SizedBox(height: 8),
        // SearchChoices with custom filtering logic
        SearchChoices.single(
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'],
              child: Text(
                option['name'] ?? 'N/A',
                style: TextStyle(color: Colors.black), // text in dropdown
              ),
            );
          }).toList(),
          value: selectedValue,
          hint: Text(
            "Выберите $label",
            style: TextStyle(color: Colors.black), // hint text
          ),
          searchHint: Text(
            "Искать $label",
            style: TextStyle(color: Colors.black), // search hint text
          ),
          onChanged: onChanged,
          isExpanded: true,
          displayClearIcon: false,
          style: TextStyle(fontSize: 14, color: Colors.black), // selected item text
          menuBackgroundColor: Colors.grey.shade50,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          searchFn: (String keyword, List<DropdownMenuItem<String>> items) {
            List<int> matchedIndexes = [];
            for (int i = 0; i < items.length; i++) {
              final item = items[i].value ?? '';
              final optionName = options.firstWhere((o) => o['id'] == item)['name'] ?? '';
              if (optionName.toLowerCase().contains(keyword.toLowerCase())) {
                matchedIndexes.add(i);
              }
            }
            return matchedIndexes;
          },
          searchInputDecoration: InputDecoration(
            hintText: "Введите для поиска",
            hintStyle: TextStyle(color: Colors.black), // search box hint text
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
          closeButton: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Закрыть",
              style: TextStyle(color: Colors.black), // close button text
            ),
          ),
        ),
      ],
    );
  }








  // Function to show success alert
  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Успех'),
        content: Text('Вы успешно зарегистрировались!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to GarageTab
                    (route) => false, // Remove all previous routes
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<void> _submitRegistration() async {
    String? _responseMessage;
    // Check if nameController.text is 'Не найдено' and don't proceed if true
    if (nameController.text == 'Не найдено') {
      setState(() {
        _responseMessage = 'Не удалось найти имя. Пожалуйста, проверьте данные.';
      });
      return; // Exit the function early if name is not found
    }

    // Validate required fields
    if (nameController.text.isEmpty ||
        tinController.text.isEmpty ||
        selectedCountry == null ||
        selectedCity == null) {
      // Show error to user that required fields are missing
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Ошибка'),
            content: Text('Пожалуйста, заполните все обязательные поля.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Send request to the registration API
    final registrationData = {
      "userType": "3",
      "name": nameController.text,
      "tin": tinController.text,
      "ein": einController.text,
      "countryID": "59ea4b0f-549f-4070-8fd3-6c7d899ea709",
      "cityID": selectedCity,
      "districtID": selectedDistrict,
      "office": officeController.text,
      "address": addressController.text,
      "activityStatusID": selectedActivityStatus,
      "actualAddress": actualAddressController.text,
      "username": usernameController.text,
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.post(
      Uri.parse('$apiUrl/entrepreneur/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(registrationData),
    );
    print(token);
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 201) {
      // Successfully registered
      print(responseData);
      _showSuccessAlert();
      print(response.body);
    } else {
      // Handle error response
      print(responseData);

      // Parse the error response if it's in JSON format (optional)
      Map<String, dynamic> errorData = {};
      try {
        errorData = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        errorData = {'message': 'Unknown error occurred'};
      }

      String errorMessage = errorData['message'] ?? 'Не удалось зарегистрироваться. Попробуйте снова.';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Ошибка'),
            content: Text(errorMessage),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
