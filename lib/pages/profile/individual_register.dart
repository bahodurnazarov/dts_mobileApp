import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search_choices/search_choices.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IndividualPage extends StatefulWidget {
  final int registrationType;

  IndividualPage({required this.registrationType});

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController _individualTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isNameFieldDisabled = true; // To manage the 'Название' field's editability
  String? _errorMessage; // To display errors if any

  bool _isLoading = false;
  String? _responseMessage;

  String? _selectedRegionID;
  String? _selectedCityID;
  String? _selectedActivityStatusID;

  List<Map<String, String>> _regionOptions = [];
  List<Map<String, String>> _cityOptions = [];
  List<Map<String, String>> _activityStatusOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/region/?page=0&size=3000&sort=id', 'region');
    _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/city/?page=0&size=3000&sort=id', 'city');
    _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/activitystatus/?page=0&size=3000&sort=id', 'activityStatus');
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
          if (type == 'region') {
            _regionOptions = options;
          } else if (type == 'city') {
            _cityOptions = options;
          } else if (type == 'activityStatus') {
            _activityStatusOptions = options;
          }
        });
      } else {
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
        Uri.parse('http://10.10.25.239:8088/?inn=$inn'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print(response.body);
        setState(() {
          nameController.text = data['fullName'] ?? "Unknown Name";
          _isNameFieldDisabled = true;  // Disable the field once the name is fetched
          _errorMessage = null; // Clear any previous errors
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Unauthorized - Invalid credentials.";
          nameController.text = "Не найдено!";
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch data. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    }
  }


  Future<void> _createIndividual() async {
    // Basic validation for username
    if (_usernameController.text.length > 9 || !RegExp(r'^\d{9}$').hasMatch(_usernameController.text)) {
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

    final url = Uri.parse('http://10.10.25.239:8088/api/v1/individual/');
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'tin': tinController.text,
      'individualType': widget.registrationType.toString(),
      'individualName': nameController.text,
      'regionID': _selectedRegionID,
      'cityID': _selectedCityID,
      'address': _addressController.text,
      'activityStatusID': _selectedActivityStatusID,
      'username': _usernameController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseMessage = 'Индивидуум успешно создан!';
        });
      } else {
        final data = jsonDecode(response.body);
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
              Text(
                'Тип регистрации: ${_getRegistrationTypeString()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 32),
              // Text fields for user input
              _buildInnField('ИНН', tinController, requiredField: true),
              _buildInnTextField('Название', nameController, requiredField: true),

              _buildTextField('Адрес', _addressController),
              _buildNumberField('Номер телефона', _usernameController, requiredField: true),
              SizedBox(height: 20),

              _buildDropdownWithSearch('Регион', _regionOptions, _selectedRegionID, (newValue) {
                setState(() {
                  _selectedRegionID = newValue;
                });
              }),
              _buildDropdownWithSearch('Город', _cityOptions, _selectedCityID, (newValue) {
                setState(() {
                  _selectedCityID = newValue;
                });
              }),
              _buildDropdownWithSearch('Статус активности', _activityStatusOptions, _selectedActivityStatusID, (newValue) {
                setState(() {
                  _selectedActivityStatusID = newValue;
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
          style: TextStyle(fontSize: 16),
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
        //SizedBox(height: 6),
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
        ),
      ],
    );
  }

}
