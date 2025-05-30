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

      if (mounted) {
        setState(() {}); // Only call setState if the widget is still mounted
      }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
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
              // Cupertino-style sections
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: tinController,
                  label: 'ИНН',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.length >= 7) _fetchNameFromInn(value);
                  },
                ),
                _buildCupertinoTextField(
                  controller: nameController,
                  label: 'Название',
                  isRequired: true,
                  isDisabled: _isNameFieldDisabled,
                ),
                _buildCupertinoTextField(
                  controller: einController,
                  label: 'ЕИН',
                  isDisabled: _isNameFieldDisabled,
                ),
                _buildCupertinoTextField(
                  controller: kppController,
                  label: 'КПП',
                ),
              ]),

              SizedBox(height: 24),

              // Address Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: addressController,
                  label: 'Адрес',
                ),
                _buildCupertinoTextField(
                  controller: officeController,
                  label: 'Дом/Кв',
                ),
              ]),

              SizedBox(height: 24),

              // Location Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: countryController,
                  label: 'Страна',
                  isDisabled: _isNameFieldDisabled,
                ),
                _buildCupertinoPicker(
                  label: 'Город',
                  value: selectedCity,
                  items: cities,
                  onChanged: (newValue) => setState(() => selectedCity = newValue),
                ),
                _buildCupertinoPicker(
                  label: 'Регион',
                  value: selectedDistrict,
                  items: districtes,
                  onChanged: (newValue) => setState(() => selectedDistrict = newValue),
                ),
              ]),

              SizedBox(height: 24),

              // Company Details Section
              _buildCupertinoSection([
                _buildCupertinoPicker(
                  label: 'Тип компании',
                  value: selectedCompanyType,
                  items: companyTypes,
                  onChanged: (newValue) => setState(() => selectedCompanyType = newValue),
                ),
                _buildCupertinoPicker(
                  label: 'Собственность',
                  value: selectedProperty,
                  items: properties,
                  onChanged: (newValue) => setState(() => selectedProperty = newValue),
                ),
              ]),

              SizedBox(height: 32),

              // Submit Button (Cupertino style)
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

  Widget _buildCupertinoSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children
            .map((child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ))
            .expand((widget) => [widget, _buildDivider()])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: CupertinoColors.separator,
      ),
    );
  }

  Widget _buildCupertinoTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isDisabled = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label${isRequired ? ' *' : ''}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // Ensures regular font
                decoration: TextDecoration.none,
                color: isDisabled
                    ? CupertinoColors.tertiaryLabel
                    : CupertinoColors.label,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Введите $label',
              placeholderStyle: TextStyle(
                color: Colors.black,
              ),
              style: TextStyle(
                fontSize: 16,  color: Colors.black, // ← Force black text color

              ),
              enabled: !isDisabled,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              onChanged: onChanged,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.transparent, // ✅ Removes default background
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCupertinoPicker({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // Ensures regular font
                decoration: TextDecoration.none,
                color: CupertinoColors.label,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                    height: 250,
                    color: Colors.black, // ✅ Light gray background instead of white
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.separator,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                child: Text(
                                  'Отмена',
                                  style: TextStyle(color: CupertinoColors.activeBlue), // Blue text
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              CupertinoButton(
                                child: Text(
                                  'Готово',
                                  style: TextStyle(color: CupertinoColors.activeBlue), // Blue text
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ],

                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            backgroundColor: Colors.white,
                            onSelectedItemChanged: (index) {
                              onChanged(items[index]['id']);
                            },
                            children: items
                                .map((item) => Center(
                              child: Text(
                                item['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black, // ✅ Force black text
                                ),
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Force black color
                    decoration: TextDecoration.none,
                  ),
                  child: Text(
                    value != null
                        ? items.firstWhere(
                          (item) => item['id'] == value,
                      orElse: () => {'name': 'Выберите'},
                    )['name']!
                        : 'Выберите',
                  ),
                ),
              ),
            ),
          ),
          Icon(
            CupertinoIcons.forward,
            size: 16,
            color: CupertinoColors.black,
          ),
        ],
      ),
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
      "propertyID": selectedProperty,
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
