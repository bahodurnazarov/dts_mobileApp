import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    transportViews = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transportview/');
    transportTypes = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transporttype/');
    transportBrands = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transportbrand/');
    transportFuels = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transportfuel/');
    transportOwnerships = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transportownership/');
    transportOwnerTypes = await _fetchDropdownOptions('http://10.10.25.239:8088/api/v1/transportownertype/');
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

      // Make the API request with the token
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token here
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody)['content'] as List;

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
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching dropdown options: $e');
      return [];
    }
  }



  // Submit function
  Future<void> _submitCar() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse('http://10.10.25.239:8088/api/v1/transport/');
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

      if (response.statusCode == 201) {
        // Show success alert
        _showSuccessAlert();
      } else {
        // Error response handling
        print(response.body);
        final responseData = json.decode(response.body);
        _showErrorAlert(responseData['content']);
      }
    } catch (error) {
      // Handle any other error
      print(error);
      _showErrorAlert('Произошла непредвиденная ошибка');
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
      appBar: AppBar(
        title: Text('Добавить машину'),
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
              _buildDropdown(
                'Тип транспорта',
                transportTypes,
                selectedTransportTypeID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportTypeID = newValue;
                  });
                },
              ),
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
              _buildDropdown(
                'Вид транспорта',
                transportViews,
                selectedTransportViewID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportViewID = newValue;
                  });
                },
              ),
              _buildDropdown(
                'Бренд транспорта',
                transportBrands,
                selectedTransportBrandID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportBrandID = newValue;
                  });
                },
              ),
              _buildDropdown(
                'Тип топлива',
                transportFuels,
                selectedTransportFuelID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportFuelID = newValue;
                  });
                },
              ),
              _buildDropdown(
                'Право собственности',
                transportOwnerships,
                selectedTransportOwnershipID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportOwnershipID = newValue;
                  });
                },
              ),
              _buildDropdown(
                'Тип владельца',
                transportOwnerTypes,
                selectedTransportOwnerTypeID,
                    (String? newValue) {
                  setState(() {
                    selectedTransportOwnerTypeID = newValue;
                  });
                },
              ),
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

  Widget _buildDropdown(String label, List<Map<String, String>> options,
      String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        hint: Text(
          label,
          style: TextStyle(color: Colors.grey[600]),  // Hint text style
        ),
        onChanged: onChanged,
        items: options.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'],
            child: Text(item['name']!, style: TextStyle(color: Colors.black)),  // Modern text color
          );
        }).toList(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),  // Rounded corners
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),  // Light border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),  // Rounded corners on focus
            borderSide: BorderSide(color: Colors.blue, width: 2),  // Focused border color
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),  // Rounded error border
            borderSide: BorderSide(color: Colors.red, width: 2),  // Error border color
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),  // Rounded error border on focus
            borderSide: BorderSide(color: Colors.red, width: 2),  // Error border on focus
          ),

        ),
      ),
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
