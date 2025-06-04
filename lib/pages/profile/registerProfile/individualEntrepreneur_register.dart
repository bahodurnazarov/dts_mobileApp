import 'dart:convert';
import 'package:dts/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';
import '../../auth/businessPage.dart';
import '../../auth/businessUserType.dart';
import '../../auth/login_page.dart';


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
  final TextEditingController officeController = TextEditingController();
  final TextEditingController actualAddressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();


  bool _isNameFieldDisabled = true; // To manage the 'Название' field's editability
  String? _errorMessage; // To display errors if any

  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;

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
    return CupertinoPageScaffold(
      backgroundColor: Colors.grey[100],
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (_) => BusinessPage()),
                (route) => false,
          ),
        ),
        middle: Text(
          'Регистрация',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: CupertinoColors.white,
        border: null,
      ),
      child: SafeArea(
        child: Form(
          child: ListView(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(height: 8),

              // Personal Info Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: tinController,
                  label: 'ИНН',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.length >= 8) _fetchNameFromInn(value);
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
                  isDisabled: _isNameFieldDisabled,
                  label: 'ЕИН',
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
                _buildCupertinoTextField(
                  controller: actualAddressController,
                  label: 'Текущий адрес',
                ),
                _buildCupertinoTextField(
                  controller: countryController,
                  label: 'Страна',
                  isDisabled: _isNameFieldDisabled,
                ),
              ]),

              SizedBox(height: 24),

              // Location Section
              _buildCupertinoSectionBorder([
                SizedBox(height: 10),
                _buildModernSearchablePicker(
                  label: 'Город',
                  value: selectedCity,
                  items: cities,
                  onChanged: (newValue) => setState(() => selectedCity = newValue),
                ),
                SizedBox(height: 10),
                _buildModernSearchablePicker(
                  label: 'Регион',
                  value: selectedDistrict,
                  items: districts,
                  onChanged: (newValue) => setState(() => selectedDistrict = newValue),
                ),
                SizedBox(height: 10),
              ]),

              SizedBox(height: 32),

              // Submit Button
              CupertinoButton(
                onPressed: _submitRegistration,
                color: CupertinoColors.activeBlue,
                borderRadius: BorderRadius.circular(8),
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Зарегистрироваться',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoSectionBorder(List<Widget> children) {
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
            .toList(), // Simply convert to list without adding dividers
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


  Widget _buildModernSearchablePicker({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showModernPickerDialog(
            context: context,
            title: label,
            items: items,
            selectedValue: value,
            onSelected: onChanged,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? items.firstWhere(
                          (item) => item['id'] == value,
                      orElse: () => {'name': 'Select an option'},
                    )['name']!
                        : 'Выберите вариант',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      color: value != null ? Colors.black : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showModernPickerDialog({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> items,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    String searchQuery = '';
    List<Map<String, String>> filteredItems = List.from(items);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Draggable handle
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Поиск...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filteredItems = items.where((item) =>
                          item['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false
                          ).toList();
                        });
                      },
                    ),
                  ),

                  // List of items
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return InkWell(
                          onTap: () {
                            onSelected(item['id']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade100,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                if (item['id'] == selectedValue)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom safe area
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
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
                MaterialPageRoute(builder: (context) => BusinessUserType('$apiUrl/entrepreneur', 3)), // Navigate to GarageTab
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
        tinController.text.isEmpty ) {
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
      "countryID": "59ea4b0f-549f-4070-8fd3-6c7d899ea709",
      "cityID": selectedCity,
      "districtID": selectedDistrict,
      "office": officeController.text,
      "address": addressController.text,
      "actualAddress": actualAddressController.text,
    };
    print(registrationData);

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
      _showSuccessAlert();
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
