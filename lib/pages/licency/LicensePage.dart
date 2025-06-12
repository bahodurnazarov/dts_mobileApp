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
          errorMessage = "Authentication required. Please login.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error retrieving token: ${e.toString()}";
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
        errorMessage = 'Authentication token not found';
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

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
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
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Widget _buildLicenseItem(Map<String, dynamic> license) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            title: Text(
              license['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            subtitle: license['text'] != null
                ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                license['text']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            )
                : null,
            children: [
              if (license['applicationDocumentTypes'] != null &&
                  (license['applicationDocumentTypes'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Required Documents:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(license['applicationDocumentTypes'] as List).map((doc) {
                        final docType = doc['documentType'] as Map<String, dynamic>?;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2, right: 8),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: CupertinoColors.activeGreen,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      docType?['name'] ?? 'Unknown Document',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Step ${doc['step']} • Importance: ${doc['documentImportance']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseList() {
    return RefreshIndicator(
      onRefresh: _fetchLicenseData,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildLicenseItem(licenseData[index]),
                childCount: licenseData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: CupertinoColors.systemRed.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: _fetchLicenseData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Licenses"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _fetchLicenseData,
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 16),
              SizedBox(height: 16),
              Text(
                'Loading licenses...',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        )
            : errorMessage.isNotEmpty
            ? _buildErrorState()
            : _buildLicenseList(),
      ),
    );
  }
}