import 'dart:async';
import 'dart:convert';

import 'package:DTS/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/globals.dart';
import '../../auth/chooseTypePage.dart';
import '../../auth/refresh_token.dart';
import '../../home_page.dart';
import '../garage_tab.dart';

class AddCarCard extends StatelessWidget {
  final VoidCallback onAddCar;

  const AddCarCard({required this.onAddCar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onAddCar,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.transparent, // Ensures no image for this card
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Добавить машину',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCarPage extends StatefulWidget {
  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  // Controllers for form fields
  TextEditingController vinController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController maxCapacityController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController imeiGpsTrackerController = TextEditingController();
  TextEditingController simGpsTrackerController = TextEditingController();

  List<Map<String, String>> transportViews = [];
  List<Map<String, String>> transportTypes = [];
  List<Map<String, String>> transportBrands = [];
  List<Map<String, String>> transportFuels = [];
  List<Map<String, String>> transportOwnerships = [];
  List<Map<String, String>> transportOwnerTypes = [];

  String? selectedTransportViewID;
  String? selectedTransportTypeID;
  String? selectedTransportBrandID;
  String? selectedTransportFuelID;
  String? selectedTransportOwnershipID;
  String? selectedTransportOwnerTypeID;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    transportViews = await _fetchDropdownOptions('$apiUrl/transportview/');
    transportTypes = await _fetchDropdownOptions('$apiUrl/transporttype/');
    transportBrands = await _fetchDropdownOptions('$apiUrl/transportbrand/?page=0&size=3000&sort=id');
    transportFuels = await _fetchDropdownOptions('$apiUrl/transportfuel/');
    transportOwnerships = await _fetchDropdownOptions('$apiUrl/transportownership/');
    transportOwnerTypes = await _fetchDropdownOptions('$apiUrl/transportownertype/');
    setState(() {});
  }

  Future<List<Map<String, String>>> _fetchDropdownOptions(String url) async {
    try {
      // Retrieve the token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token not found in cache');
      }
      // Make the API request with the token and a timeout
      final response = await http
          .get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token here
          'accept': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 10), // Set the timeout duration
        onTimeout: () {
          throw TimeoutException('Request to $url timed out');
        },
      );

      print(globalUserType);
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = json.decode(decodedBody);

        // Log the parsed JSON for debugging

        final data = jsonResponse['content'] as List?;

        if (data == null) {
          throw Exception('No content found in response');
        }

        // Determine how to map the response based on the URL
        if (url.contains('transporttype')) {
          return data
              .map((item) => {
            'id': item['id'].toString(),
            'name': item['type'].toString(), // Use 'type' for transportTypes
          })
              .toList();
        } else {
          return data
              .map((item) => {
            'id': item['id'].toString(),
            'name': item['name'].toString(), // Default mapping
          })
              .toList();
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return []; // Return an empty list on timeout
    } catch (e) {
      print('Error fetching dropdown options: $e');
      return [];
    }
  }


  Future<void> _submitCar() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse('$apiUrl/transport/');
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token', // Include the token here
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "vinCod": vinController.text,
      "transportViewID": selectedTransportViewID,
      "transportTypeID": selectedTransportTypeID,
      "transportBrandID": selectedTransportBrandID,
      "model": modelController.text,
      "year": yearController.text,
      "carNumber": carNumberController.text,
      "transportFuelID": selectedTransportFuelID,
      "capacity": capacityController.text,
      "maxCapacity": maxCapacityController.text,
      "height": heightController.text,
      "weight": weightController.text,
      "longth": lengthController.text,
      "imeiGpsTracker": imeiGpsTrackerController.text,
      "simGpsTracker": simGpsTrackerController.text,
      "transportOwnerShipID": selectedTransportOwnershipID,
      "transportOwnerTypeID": selectedTransportOwnerTypeID,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Check the HTTP status code
      if (response.statusCode == 201) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final transportId = responseData['content']['id'];

        await _addTransportToUser(transportId);

        _showSuccessAlert();
      } else {
        // Handle non-201 responses
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        print(response.body);
        _showErrorAlert(responseData['content']);
      }
    } catch (error) {
      // Handle any other error
      print(error);
      _showErrorAlert('Произошла непредвиденная ошибка');
    }
  }


  Future<void> _addTransportToUser(String transportId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String baseApiUrl = ''; // Initialize apiUrl with an empty string

    // Set the appropriate API URL based on the userType
    switch (globalUserType) {
      case 1:
        baseApiUrl = '$apiUrl/individual/$globalUserId/transport?transportId=$transportId';
        break;
      case 3:
        baseApiUrl = '$apiUrl/entrepreneur/$globalUserId/transport?transportId=$transportId';
        break;
      case 2:
        baseApiUrl = '$apiUrl/company/$globalUserId/transport?transportId=$transportId';
        break;
      case 0:
      // If globalUserType = 0, navigate to ChooseTypePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseTypePage(),
          ),
        );
        return; // Prevent further execution after navigation
      default:
        print("Invalid user type");
        return;
    }
    final individualUrl = Uri.parse(baseApiUrl);
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Send POST request
      final response = await http.post(individualUrl, headers: headers);
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        print("Transport added successfully");
      } else {
        // Handle non-201 responses
        print("Failed to add transport: ${response.body}");
        _showErrorAlert(responseData['message'] ?? "Error occurred");
      }
    } catch (error) {
      // Handle any errors during the second request
      print("Error during second request: $error");
      _showErrorAlert("Произошла непредвиденная ошибка");
    }
  }


  // Function to show success alert
  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Успех'),
        content: Text('Машина успешно добавлена!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Navigate to GarageTab
                    (route) => false, // Remove all previous routes
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to show error alert
  void _showErrorAlert(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ошибка'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: Text('Добавить машину'),
        backgroundColor: Colors.white, // Set background color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: transportViews.isEmpty ||
            transportTypes.isEmpty ||
            transportBrands.isEmpty ||
            transportFuels.isEmpty ||
            transportOwnerships.isEmpty ||
            transportOwnerTypes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildDropdownWithSearch('Тип транспорта', transportTypes, selectedTransportTypeID, (newValue) {
                setState(() {
                  selectedTransportTypeID = newValue;
                });
              }),

              _buildTextField('VIN Код', vinController),
              _buildTextField('Марка', modelController),
              _buildTextField('Год выпуска', yearController),
              _buildTextField('Номер машины', carNumberController),
              _buildTextField('Емкость', capacityController),
              _buildTextField('Макс. емкость', maxCapacityController),
              _buildTextField('Высота', heightController),
              _buildTextField('Вес', weightController),
              _buildTextField('Длина', lengthController),
              _buildTextField('IMEI GPS-трекера', imeiGpsTrackerController),
              _buildTextField('SIM GPS-трекера', simGpsTrackerController),

              _buildDropdownWithSearch('Вид транспорта', transportViews, selectedTransportViewID, (newValue) {
                setState(() {
                  selectedTransportViewID = newValue;
                });
              }),

              _buildDropdownWithSearch('Бренд транспорта', transportBrands, selectedTransportBrandID, (newValue) {
                setState(() {
                  selectedTransportBrandID = newValue;
                });
              }),

              _buildDropdownWithSearch('Тип топлива', transportFuels, selectedTransportFuelID, (newValue) {
                setState(() {
                  selectedTransportFuelID = newValue;
                });
              }),

              _buildDropdownWithSearch('Право собственности', transportOwnerships, selectedTransportOwnershipID, (newValue) {
                setState(() {
                  selectedTransportOwnershipID = newValue;
                });
              }),

              _buildDropdownWithSearch('Тип владельца', transportOwnerTypes, selectedTransportOwnerTypeID, (newValue) {
                setState(() {
                  selectedTransportOwnerTypeID = newValue;
                });
              }),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Padding for better button size
                  elevation: 5, // Subtle shadow/elevation effect
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Text style
                ),
                child: Text('Добавить машину'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
          closeButton: TextButton(
            onPressed: () {
              // Implement close action
              Navigator.pop(context); // Close the dropdown
            },
            child: Text(
              "Закрыть", // Russian for "Close"
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.black, fontSize: 16),  // Modern font style
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),  // Lighter label text
          hintText: label,  // Add hint text for a better UX
          hintStyle: TextStyle(color: Colors.grey[400]),  // Gray hint text
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),  // Focused border with color
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),  // Regular border color
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),  // Red border when error
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),  // Error border when focused
            borderRadius: BorderRadius.circular(12),  // Rounded corners
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }

}
