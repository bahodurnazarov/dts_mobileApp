import 'dart:async'; // Import for Timer
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../utils/services.dart';
import 'login_page.dart';

class OTPScreen extends StatefulWidget {
  final String login;
  final String username;

  const OTPScreen({Key? key, required this.login, required this.username}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpValid = false;
  int _remainingTime = 120; // Countdown timer duration set to 2 minutes (120 seconds)
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_validateOtp);
    _startTimer(); // Start the timer when the OTP screen is initialized
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer!.cancel(); // Stop the timer when it reaches zero
        }
      });
    });
  }

  void _validateOtp() {
    setState(() {
      _isOtpValid = _otpController.text.length == 6; // Assuming OTP is 6 digits
    });
  }

  // Function to verify OTP
  Future<void> verifyOtp() async {
    PhoneNumberConverter converter = PhoneNumberConverter();
    String plainPhoneNumber = converter.convertToPlainPhoneNumber(widget.login);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/confirm?login=${plainPhoneNumber}&code=${_otpController.text.trim()}'),
        headers: {"accept": "*/*"},
      );

      if (response.statusCode == 200) {
        // Successful OTP verification
        final responseData = jsonDecode(utf8.decode(response.bodyBytes)); // Decode response using UTF-8
        final message = responseData['content'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Успех'),
              content: Text(message ?? 'Логин и пароль отправлены на ваш номер!'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to the next page if needed
                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) =>LoginPage())
                    );
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        // Invalid OTP case
        final responseData = jsonDecode(utf8.decode(response.bodyBytes)); // Decode using UTF-8
        final errorMessage = responseData['message'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Ошибка'),
              content: Text(errorMessage ?? 'Неверный код регистрации'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle other status codes
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Ошибка'),
            content: Text('Произошла ошибка. Пожалуйста, попробуйте снова.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Ошибка'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('ОК'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.blue[300]!;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically
            children: [
              SizedBox(height: 60),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                  children: [
                    Text(
                      'Введите код подтверждения',
                      textAlign: TextAlign.center, // Center text within the Text widget
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Код был отправлен на ваш номер телефона: ${widget.login.replaceRange(2, widget.login.length - 3, '*' * (widget.login.length - 5))}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              CupertinoCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildOtpTextField(),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: _isOtpValid ? Colors.blue : CupertinoColors.systemGrey,
                          onPressed: _isOtpValid ? verifyOtp : null,
                          borderRadius: BorderRadius.circular(25),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Подтвердить',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: _resendOtp, //_remainingTime <= 0 ? _resendOtp : null, // Enable resend button only when time is up
                        child: const Text(
                          'Не получили код?',
                          style: TextStyle(color: CupertinoColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20), // Space between the card and the timer
              Text(
                'Осталось времени: ${_remainingTime} секунд!',
                style: TextStyle(color: CupertinoColors.white, fontSize: 16, decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Успех'),
          content: Text(message ?? 'Логин и пароль отправлены на ваш номер!'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        );
      },
    );
  }

  void _resetTimer() {
    setState(() {
      _remainingTime = 120; // Reset timer to 120 seconds
      _startTimer(); // Start the timer again
    });
  }

  Future<void> _resendOtp() async {

    PhoneNumberConverter converter = PhoneNumberConverter();
    String plainPhoneNumber = converter.convertToPlainPhoneNumber(widget.login);
    print(widget.username);
    print(plainPhoneNumber);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": widget.username,
          "username": plainPhoneNumber,
        }),
      );

      // Decode the response as UTF-8 and then parse JSON
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        _showSuccessDialog(responseData['content']);
        // Delay navigation to allow user to read the success message
        await Future.delayed(Duration(seconds: 2));

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OTPScreen(
              login: widget.login,
              username: widget.username, // Pass username here
            ),
          ),
        );
      } else {
        _showErrorDialog(responseData['message'] ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  Widget _buildOtpTextField() {
    return CupertinoTextField(
      controller: _otpController,
      placeholder: 'Введите 6-значный код',
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.lightBackgroundGray,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey2.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      style: TextStyle(fontSize: 16),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6), // Limit to 6 digits
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
