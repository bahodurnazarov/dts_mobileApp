import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isPhoneValid = false;
  bool _isOTPValid = false;
  bool _isOtpReceived = false;
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _otpController.addListener(_isOTPCode); // Add listener for OTP
  }


  void _isOTPCode() {
    setState(() {
      _isOTPValid = _otpController.text.length == 6;
    });
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.length == 9;
    });
  }

  void _validateOtp() {
    setState(() {
      // Check if the OTP is exactly 6 digits long
    });
  }

  Future<void> requestOTP() async {
    final phoneNumber = _phoneController.text.trim();
    print('Requesting OTP for phone number: $phoneNumber');

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('$authUrl/auth/restore-password'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": "empty",
          "username": phoneNumber,
          "userType": "",
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        setState(() {
          _isOtpReceived = true;
        });
        _showCustomDialog('Код был отправлен на ваш номер телефона.');
      } else {
        print('Error Response: ${response.body}');
        _showCustomDialog(responseData['message'] ?? 'Произошла ошибка.');
      }
    } catch (e) {
      _showCustomDialog('Произошла ошибка: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> confirmOTP() async {
    final phoneNumber = _phoneController.text.trim();
    final otpCode = _otpController.text.trim();

    if (otpCode.length == 6) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        final response = await http.put(
          Uri.parse(
              '$authUrl/auth/confirm-password?login=$phoneNumber&code=$otpCode'),
          headers: {"accept": "*/*"},
        );

        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200) {
          // Show dialog first
          _showCustomDialog(
              responseData['content'] ?? 'Пароль успешно обновлён.');

          // Wait for 5 seconds before navigating to LoginPage
          await Future.delayed(Duration(seconds: 5));

          // Navigate to LoginPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          _showCustomDialog(responseData['message'] ?? 'Неверный код.');
        }
      } catch (e) {
        _showCustomDialog('Произошла ошибка: $e');
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    } else {
      _showCustomDialog('Код должен содержать 6 цифр.');
    }
  }

  void _showCustomDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // Set the background color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Add rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add some padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Make the dialog size wrap its content
              children: [
                Text(
                  'Сообщение',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Black text for the title
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Black text for the message
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.blue, // Button text color
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.blue[300]!,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Введите номер телефона',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CupertinoCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          _phoneController,
                          'Номер телефона',
                          CupertinoIcons.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _otpController,
                                'Введите код',
                                CupertinoIcons.lock,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            CupertinoButton(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              borderRadius: BorderRadius.circular(25),
                              color: _isPhoneValid
                                  ? Colors.blue
                                  : CupertinoColors.systemGrey,
                              onPressed: _isPhoneValid && !_isLoading
                                  ? requestOTP
                                  : null,
                              child: Text(
                                'Получить код',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: _isOTPValid ? Colors.blue : CupertinoColors
                                .systemGrey,
                            // Button color based on validity
                            onPressed: _isOTPValid && !_isLoading
                                ? confirmOTP
                                : null,
                            // Enable button only if OTP is valid
                            borderRadius: BorderRadius.circular(25),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            // Adjusted padding
                            child: Text(
                              'Подтвердить', // The text remains the same
                              style: TextStyle(
                                fontSize: 18, // Font size
                                fontWeight: FontWeight
                                    .w600, // Adjusted font weight
                              ),
                            ),
                          ),
                        ),
                      ],
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
        List<TextInputFormatter>? inputFormatters,
      }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: TextInputType.phone,
      placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(icon, color: CupertinoColors.systemGrey2),
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.lightBackgroundGray,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      style: TextStyle(fontSize: 16, color: Colors.black),
      inputFormatters: inputFormatters ?? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9), // Limit to 9 digits
      ],
    );
  }
}

  class CupertinoCard extends StatelessWidget {
  final Widget child;

  const CupertinoCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
