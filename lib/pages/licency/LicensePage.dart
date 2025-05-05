import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/config.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  bool isLoading = true;
  String? token;
  List<Map<String, dynamic>> licenseData = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchLicense();
  }

  Future<void> _loadTokenAndFetchLicense() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedToken = prefs.getString('auth_token');

      if (storedToken != null && storedToken.isNotEmpty) {
        setState(() {
          token = storedToken;
        });
        await _fetchLicenseData();
      } else {
        setState(() {
          errorMessage = "Token not found.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error retrieving token: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchLicenseData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token not found';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$apiUrl/permit-application-list/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );
      //final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        // Properly decode the UTF-8 response
        final data = json.decode(utf8.decode( response.bodyBytes));
        // Convert the List<dynamic> to List<Map<String, dynamic>>
        final List<dynamic> content = data['content'];
        final List<Map<String, dynamic>> convertedData = content.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();

        setState(() {
          licenseData = convertedData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load license data (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        print(e);
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildLicenseItem(Map<String, dynamic> license) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              license['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              license['text'] ?? 'No Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (license['applicationDocumentTypes'] != null &&
                (license['applicationDocumentTypes'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Documents:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...(license['applicationDocumentTypes'] as List).map((doc) {
                    final docType = doc['documentType'] as Map<String, dynamic>?;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '- ${docType?['name'] ?? 'Unknown Document'} (Step ${doc['step']}, Importance: ${doc['documentImportance']})',
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseList() {
    return ListView.builder(
      itemCount: licenseData.length,
      itemBuilder: (context, index) {
        return _buildLicenseItem(licenseData[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("License Applications"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildLicenseList(),
        ),
      ),
    );
  }
}