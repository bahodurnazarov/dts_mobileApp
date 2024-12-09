import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../utils/services.dart';
import 'login_page.dart';
import 'otp.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
    _userTypeController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty;
    });
  }

  Future<void> registerUser() async {
    PhoneNumberConverter converter = PhoneNumberConverter();
    String plainPhoneNumber = converter.convertToPlainPhoneNumber(_usernameController.text.trim());
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _nameController.text.trim(),
          "username": plainPhoneNumber,
          "userType": "1"
        }),
      );

      // Check the status code and handle accordingly
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Handle successful registration
        _showSuccessDialog(responseData['content']);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OTPScreen(
              login: _usernameController.text.trim(),
              username: _nameController.text.trim(),
            ),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        switch (responseData['statusCode']) {
          case 400:
            _showErrorDialog(responseData['content'] ?? 'Validation failed. Please check your input.');
            break;
          case 409:
            _showErrorDialog(responseData['message'] ?? 'User already exists. Please use a different username.');
            break;
          default:
            _showErrorDialog('An unexpected error occurred. Please try again later.');
            break;
        }
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }


  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Ошибка'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.blue[300]!;

    return WillPopScope(
      onWillPop: () async {
        // Handle the back button or swipe gesture manually
        return false; // Disable going back/swiping back
      },
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 130),
                Center(
                  child: Text(
                    'Создать аккаунт',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                CupertinoCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(_nameController, 'ФИО', CupertinoIcons.person),
                        SizedBox(height: 20),
                        _buildTextField(
                          _usernameController,
                          'Phone number',
                          CupertinoIcons.phone,
                          isDigitField: true,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(_userTypeController, 'Тип пользователя', CupertinoIcons.info),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: _isFormValid ? Colors.blue : CupertinoColors.systemGrey,
                            onPressed: _isFormValid ? registerUser : null,
                            borderRadius: BorderRadius.circular(25),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Зарегистрироваться',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25),
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Уже есть аккаунт? Войти',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(
      TextEditingController controller,
      String placeholder,
      IconData icon, {
        bool isDigitField = false,
      }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: isDigitField ? '987-27-57-57' : placeholder,
      placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: isDigitField
            ? Row(
          children: [
            Icon(icon, color: CupertinoColors.systemGrey),
            SizedBox(width: 15), // Space between icon and text
            Text(
              '(+992)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // Set to regular weight
                decoration: TextDecoration.none,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        )
            : Icon(icon, color: CupertinoColors.systemGrey),
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.lightBackgroundGray,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      style: TextStyle(fontSize: 16, color: Colors.black),
      keyboardType: isDigitField ? TextInputType.number : TextInputType.text,
      inputFormatters: isDigitField
          ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9), // Limit to 9 digits
        PhoneNumberFormatter(), // Custom formatter for phone number format
      ]
          : [],
    );
  }




  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _userTypeController.dispose();
    super.dispose();
  }
}

class CupertinoCard extends StatelessWidget {
  final Widget child;

  const CupertinoCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            spreadRadius: 2.0,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
