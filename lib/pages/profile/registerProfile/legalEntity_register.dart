import 'dart:convert';
import 'package:DTS/pages/profile/profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';


class LegalRegistrationPage extends StatefulWidget {
  final int registrationType;

  LegalRegistrationPage({required this.registrationType});

  @override
  _LegalRegistrationPageState createState() => _LegalRegistrationPageState();
}

class _LegalRegistrationPageState extends State<LegalRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController einController = TextEditingController();
  final TextEditingController kppController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController officeController = TextEditingController();
  final TextEditingController actualAddressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();


  bool _isNameFieldDisabled = true; // To manage the 'Название' field's editability
  String? _errorMessage; // To display errors if any

  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedCompanyType;
  String? selectedActivityStatus;
  String? selectedProperty;

  List<Map<String, String>> countries = [];
  List<Map<String, String>> cities = [];
  List<Map<String, String>> districtes = [];
  List<Map<String, String>> companyTypes = [];
  List<Map<String, String>> activityStatuses = [];
  List<Map<String, String>> properties = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {


    try {
      countries = await _fetchDropdownOptions('$apiUrl/country/?page=0&size=3000&sort=id');
      cities = await _fetchDropdownOptions('$apiUrl/city/?page=0&size=3000&sort=id');
      districtes = await _fetchDropdownOptions('$apiUrl/district/?page=0&size=3000&sort=id');
      companyTypes = await _fetchDropdownOptions('$apiUrl/companytype/?page=0&size=3000&sort=id');
      activityStatuses = await _fetchDropdownOptions('$apiUrl/activitystatus/?page=0&size=3000&sort=id');
      properties = await _fetchDropdownOptions('$apiUrl/property/');
      setState(() {});
    } catch (e) {
      print('Error loading dropdown data: $e');
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
        Uri.parse('http://10.10.25.239:8088/?inn=$inn'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedResponse);

      if (response.statusCode == 200) {
        // Successful response
        print(data);
        setState(() {
          nameController.text = data['fullName'] ?? "Unknown Name";
          nameController.text = data['fullName'] ?? "Unknown Name";
          countryController.text = "Таджикистан";
          einController.text = data['ein'] ?? "Unknown Name";
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
        throw Exception('Unauthorized access. Please check your credentials.');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
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
              _buildTextField('КПП', kppController),
              _buildTextField('Адрес', addressController),
              _buildTextField('Дом/Кв', officeController),
              _buildTextField('Широта', latitudeController),
              _buildTextField('Долгота', longitudeController),
              _buildNumberField('Номер телефона', usernameController, requiredField: true),

              SizedBox(height: 32),

              _buildInnTextField('Страна', countryController),

              // // Dropdowns for registration
              // _buildDropdownWithSearch('Страна', countries, selectedCountry, (newValue) {
              //   setState(() {
              //     selectedCountry = newValue;
              //   });
              // }),
              _buildDropdownWithSearch('Город', cities, selectedCity, (newValue) {
                setState(() {
                  selectedCity = newValue;
                });
              }),

              _buildDropdownWithSearch('Регион', districtes, selectedDistrict, (newValue) {
                setState(() {
                  selectedDistrict = newValue;
                });
              }),

              _buildDropdownWithSearch('Тип компании', companyTypes, selectedCompanyType, (newValue) {
                setState(() {
                  selectedCompanyType = newValue;
                });
              }),
              _buildDropdownWithSearch('Статус', activityStatuses, selectedActivityStatus, (newValue) {
                setState(() {
                  selectedActivityStatus = newValue;
                });
              }),
              _buildDropdownWithSearch('Собственность', properties, selectedProperty, (newValue) {
                setState(() {
                  selectedProperty = newValue;
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

  Widget _buildTextField(String label, TextEditingController controller, {bool requiredField = false}) {
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
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(fontSize: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
        ),
        // Display a star next to label if the field is required
        SizedBox(height: 6),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {bool requiredField = false}) {
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
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          style: TextStyle(fontSize: 16),
          keyboardType: TextInputType.number, // Restrict to number input
          inputFormatters: [
            // Optional: Format input to only allow digits
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CupertinoColors.inactiveGray),
          ),
        ),
        // Display a star next to label if the field is required
        SizedBox(height: 6),
      ],
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
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        // SearchChoices with custom filtering logic
        SearchChoices.single(
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'],
              child: Text(option['name'] ?? 'N/A'),
            );
          }).toList(),
          value: selectedValue,
          hint: Text("Выберите $label"), // Russian translation
          searchHint: Text("Искать $label"), // Russian translation
          onChanged: onChanged,
          isExpanded: true,
          displayClearIcon: false,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          menuBackgroundColor: Colors.grey.shade50,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          searchFn: (String keyword, List<DropdownMenuItem<String>> items) {
            // Custom search function
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
            hintText: "Введите для поиска", // Russian translation
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
          closeButton: TextButton(
            onPressed: () {
              // Implement close action
              Navigator.pop(context); // Close the dropdown
            },
            child: Text(
              "Закрыть", // Russian for "Close"
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }







  String _getRegistrationTypeString() {
    switch (widget.registrationType) {
      case 1:
        return "Физ. лицо";
      case 2:
        return "Юр. лицо";
      case 3:
        return "ИП";
      default:
        return "Не выбран";
    }
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
        selectedCity == null ||
        selectedDistrict == null ||
        selectedCompanyType == null ||
        selectedActivityStatus == null ||
        selectedProperty == null) {
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
      "userType": widget.registrationType.toString(),
      "name": nameController.text,
      "tin": tinController.text,
      "ein": einController.text,
      "kpp": kppController.text,
      "countryID": "59ea4b0f-549f-4070-8fd3-6c7d899ea709",
      "cityID": selectedCity,
      "districtID": selectedDistrict,
      "office": officeController,
      "address": addressController.text,
      "companyTypeID": selectedCompanyType,
      "activityStatusID": selectedActivityStatus,
      "latitude": latitudeController.text,
      "longitude": longitudeController.text,
      "propertyID": selectedProperty,
      "username": usernameController.text,
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$apiUrl/company/'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(registrationData),
    );
    if (response.statusCode == 201) {
      // Successfully registered
      _showSuccessAlert();
      print(response.body);
    } else {
      // Handle error response (e.g., show a message)
      print(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Ошибка'),
            content: Text('Не удалось зарегистрироваться. Попробуйте снова.'),
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
