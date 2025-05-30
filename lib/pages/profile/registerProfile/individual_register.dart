import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/config.dart';
import '../../auth/businessPage.dart';
import '../../auth/login_page.dart';

class IndividualPage extends StatefulWidget {

  IndividualPage();

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController _individualTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();


  bool _isNameFieldDisabled = true; // To manage the 'Название' field's editability
  String? _errorMessage; // To display errors if any

  bool _isLoading = false;
  String? _responseMessage;

  String? _selectedCityID;
  String? _selectedDistrictID;
  String? _selectedActivityStatusID;


  List<Map<String, String>> _countryOptions = [];
  List<Map<String, String>> _cityOptions = [];
  List<Map<String, String>> _districtOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions('$apiUrl/country/?page=0&size=3000&sort=id', 'country');
    _fetchDropdownOptions('$apiUrl/city/?page=0&size=3000&sort=id', 'city');
    _fetchDropdownOptions('$apiUrl/district/?page=0&size=3000&sort=id', 'district');
    _fetchDropdownOptions('$apiUrl/activitystatus/?page=0&size=3000&sort=id', 'activityStatus');
  }

  Future<void> _fetchDropdownOptions(String url, String type) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in cache');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );
      print(url);
      print(token);
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody)['content'] as List;
        List<Map<String, String>> options = data
            .map((item) => {
          'id': item['id'].toString(),
          'name': item['name'].toString(),
        })
            .toList();
        setState(() {
          if (type == 'country') {
            _countryOptions = options;
          } else if (type == 'city') {
            _cityOptions = options;
          } else if (type == 'district') {
            _districtOptions = options;
          }
        });
      } else {
        if (response.statusCode == 401) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          return;
        }
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dropdown options: $e');
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
      print(data);
      if (response.statusCode == 200) {
        // Successful response
        setState(() {
          nameController.text = data['fullName'] ?? "Unknown Name";
          countryController.text = "Таджикистан";
          _isNameFieldDisabled = true; // Disable the field after fetching
          _errorMessage = null; // Clear any previous errors
        });
      } else if (response.statusCode == 404) {
        // INN not found
        setState(() {
          nameController.text = "Не найдено"; // Display "Not Found" in Russian
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




  Future<void> _createIndividual() async {
    // Check if nameController.text is 'Не найдено' and don't proceed if true
    if (nameController.text == 'Не найдено') {
      setState(() {
        _responseMessage = 'Не удалось найти имя. Пожалуйста, проверьте данные.';
      });
      return; // Exit the function early if name is not found
    }

    // Basic validation for username
    if (_usernameController.text.length != 9 || !RegExp(r'^\d{9}$').hasMatch(_usernameController.text)) {
      setState(() {
        _responseMessage = 'Имя пользователя должно содержать ровно 9 цифр.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse('$apiUrl/individual/');
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'tin': tinController.text,
      'individualName': nameController.text,
      'countryID': "59ea4b0f-549f-4070-8fd3-6c7d899ea709",
      'cityID': _selectedCityID,
      'districtID': _selectedDistrictID,
      "office": _officeController.text,
      'address': _addressController.text,
      'username': _usernameController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 201) {
        final data = jsonDecode(decodedBody);
        print(data);
        setState(() {
          _responseMessage = 'Индивидуум успешно создан!';
        });
      } else {
        final data = jsonDecode(decodedBody);
        print(data);
        setState(() {
          _responseMessage = data['message'];
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _responseMessage = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  void dispose() {
    tinController.dispose();
    _individualTypeController.dispose();
    nameController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    super.dispose();
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
              // Personal Information Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: tinController,
                  label: 'ИНН',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    // Add any INN validation logic if needed
                      if (value.length >= 7) _fetchNameFromInn(value);
                  },
                ),
                _buildCupertinoTextField(
                  controller: nameController,
                  label: 'ФИО',
                  isRequired: true,
                ),
              ]),

              SizedBox(height: 24),

              // Address Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: _addressController,
                  label: 'Адрес',
                ),
                _buildCupertinoTextField(
                  controller: _officeController,
                  label: 'Дом/Кв',
                ),
              ]),

              SizedBox(height: 24),

              // Contact Information Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: _usernameController,
                  label: 'Номер телефона',
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ]),

              SizedBox(height: 24),

              // Location Section
              _buildCupertinoSection([
                _buildCupertinoTextField(
                  controller: countryController,
                  label: 'Страна',
                ),
                _buildCupertinoPicker(
                  label: 'Город',
                  value: _selectedCityID,
                  items: _cityOptions,
                  onChanged: (newValue) => setState(() => _selectedCityID = newValue),
                ),
                _buildCupertinoPicker(
                  label: 'Регион',
                  value: _selectedDistrictID,
                  items: _districtOptions,
                  onChanged: (newValue) => setState(() => _selectedDistrictID = newValue),
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
                    _createIndividual();
                  },
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              // Response Message
              if (_responseMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _responseMessage!,
                    style: TextStyle(
                      color: _responseMessage!.contains('успешно')
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemRed,
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
                color: Colors.grey,
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
}
