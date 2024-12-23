import 'dart:convert';
import 'package:DTS/pages/auth/restore_password.dart';
import 'package:DTS/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../../utils/services.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.length >= 8;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> loginUser() async {
    PhoneNumberConverter converter = PhoneNumberConverter();
    String plainPhoneNumber = converter.convertToPlainPhoneNumber(_usernameController.text.trim());
    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": plainPhoneNumber,
          "password": _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        // Save token to cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['access_token']);

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => HomePage()),
        );
      } else {
        final responseData = json.decode(response.body);
        _showErrorDialog(
            responseData['message'] ?? 'Invalid username or password.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }


  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) =>
          CupertinoAlertDialog(
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

  Future<bool> _onWillPop() async {
    return false; // Prevent back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Disable back-swipe and back button
      child: CupertinoPageScaffold(
        backgroundColor: Colors.blue[300]!,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 150),
                Center(
                  child: Text(
                    'Войти в аккаунт',
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
                        _buildTextField(
                          _usernameController,
                          'Имя пользователя',
                          CupertinoIcons.phone,
                          isDigitField: true, // Restrict this field to digits only
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          _passwordController,
                          'Пароль',
                          CupertinoIcons.lock,
                          isPasswordField: true, // For password field
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: _isFormValid ? Colors.blue : CupertinoColors.systemGrey,
                            onPressed: _isFormValid ? loginUser : null,
                            borderRadius: BorderRadius.circular(25),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Войти',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
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
                      CupertinoPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Нет аккаунта? Зарегистрироваться',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Забыли пароль?',
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

  Widget _buildTextField(TextEditingController controller,
      String placeholder,
      IconData icon, {
        bool isPasswordField = false,
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
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        )
            : Icon(icon, color: CupertinoColors.systemGrey),
      ),
      suffix: isPasswordField
          ? GestureDetector(
        onTap: _togglePasswordVisibility,
        child: Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Icon(
            _isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: CupertinoColors.systemGrey,
          ),
        ),
      )
          : null,
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
      obscureText: isPasswordField ? !_isPasswordVisible : false,
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
