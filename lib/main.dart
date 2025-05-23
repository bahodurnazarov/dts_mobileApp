import 'dart:ui';

import 'package:dts/pages/auth/login_page.dart';
import 'package:dts/pages/home_page.dart';
import 'package:dts/pages/lessons/lessons_page.dart';
import 'package:dts/pages/navigator/MapScreen.dart';
import 'package:dts/pages/profile/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'logging_service.dart';


void main() async {
  // Initialize logging
  WidgetsFlutterBinding.ensureInitialized();
  await LoggingService.initialize();

  // Catch and log all errors
  FlutterError.onError = (details) {
    LoggingService.log('Flutter error: ${details.exception}', level: Level.error);
    if (details.stack != null) {
      LoggingService.log('Stack trace: ${details.stack}', level: Level.error);
    }
  };

  // Catch and log Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.log('Dart error: $error', level: Level.error);
    LoggingService.log('Stack trace: $stack', level: Level.error);
    return true;
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DTS',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomeWrapper(),
      supportedLocales: [
        Locale("en", "US"), // English locale
        Locale("ru", "RU"), // Russian locale
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}



class HomeWrapper extends StatefulWidget {
  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('auth_token');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator while fetching token
        ),
      );
    }


    // If token is null or empty, navigate to LoginPage
    if (token == null || token!.isEmpty) {
      return NavigatorTab();
    }

    // Otherwise, navigate to HomePage
    return NavigatorTab();
  }
}
