import 'dart:async';
import 'dart:convert';
import 'package:dts/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/globals.dart';
import '../../auth/businessPage.dart';
import '../../auth/privateAccountPage.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  //region Controllers
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _imeiGpsTrackerController = TextEditingController();
  final TextEditingController _simGpsTrackerController = TextEditingController();
  final TextEditingController _registrationCertificateSeriesController = TextEditingController();
  final TextEditingController _bodyNoController = TextEditingController();
  final TextEditingController _bodyTypeController = TextEditingController();
  final TextEditingController _carBrandController = TextEditingController();
  final TextEditingController _chassisNoController = TextEditingController();
  final TextEditingController _engineCapacityController = TextEditingController();
  final TextEditingController _enginePowerHpController = TextEditingController();
  final TextEditingController _enginePowerKwController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _maxWeightLadenController = TextEditingController();
  final TextEditingController _maxWeightUnladenController = TextEditingController();
  final TextEditingController _numberOfSeatsController = TextEditingController();
  final TextEditingController _vehiclePassportController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  //endregion

  //region Dropdown Data
  List<Map<String, String>> _transportViews = [];
  List<Map<String, String>> _transportTypes = [];
  List<Map<String, String>> _transportBrands = [];
  List<Map<String, String>> _transportFuels = [];
  List<Map<String, String>> _transportOwnerships = [];
  List<Map<String, String>> _transportOwnerTypes = [];
  //endregion

  //region Selected Dropdown Values
  String? _selectedTransportViewID;
  String? _selectedTransportTypeID;
  String? _selectedTransportBrandID;
  String? _selectedTransportFuelID;
  String? _selectedTransportOwnershipID;
  String? _selectedTransportOwnerTypeID;
  //endregion

  //region Loading States
  bool _isLoading = false;
  bool _isFetchingCarData = false;
  //endregion

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _vinController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _carNumberController.dispose();
    _capacityController.dispose();
    _maxCapacityController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _imeiGpsTrackerController.dispose();
    _simGpsTrackerController.dispose();
    _registrationCertificateSeriesController.dispose();
    _bodyNoController.dispose();
    _bodyTypeController.dispose();
    _carBrandController.dispose();
    _chassisNoController.dispose();
    _engineCapacityController.dispose();
    _enginePowerHpController.dispose();
    _enginePowerKwController.dispose();
    _engineTypeController.dispose();
    _maxWeightLadenController.dispose();
    _maxWeightUnladenController.dispose();
    _numberOfSeatsController.dispose();
    _vehiclePassportController.dispose();
    _phoneController.dispose();
    _colorController.dispose();
    _typeController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    if (_isLoading) return; // Prevent multiple calls

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        _showErrorAlert('Authentication token not found. Please log in again.');
        return;
      }

      await Future.wait([
        _fetchDropdownOptions('$apiUrl/transportview/', token).then((data) => _transportViews = data),
        _fetchDropdownOptions('$apiUrl/transporttype/', token, keyMap: {'id': 'id', 'name': 'type'},).then((data) => _transportTypes = data),
        _fetchDropdownOptions('$apiUrl/transportbrand/?page=0&size=3000&sort=id', token).then((data) => _transportBrands = data),
        _fetchDropdownOptions('$apiUrl/transportfuel/', token).then((data) => _transportFuels = data),
        _fetchDropdownOptions('$apiUrl/transportownership/', token).then((data) => _transportOwnerships = data),
        _fetchDropdownOptions('$apiUrl/transportownertype/', token).then((data) => _transportOwnerTypes = data),
      ]);
    } on Exception catch (e) {
      _showErrorAlert('Failed to load dropdown data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCarData() async {
    if (_carNumberController.text.isEmpty || _registrationCertificateSeriesController.text.isEmpty) {
      _showErrorAlert('Пожалуйста, введите номер машины и серию свидетельства о регистрации');
      return;
    }

    setState(() {
      _isFetchingCarData = true;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final uri = Uri.parse(
          '$apiUrl/transport/check/bridge?licensePlate=${_carNumberController.text}&registrationCertificateSeries=${Uri.encodeComponent(_registrationCertificateSeriesController.text)}');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final carData = jsonResponse['content'];
        _updateCarFields(carData);
      } else {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        _showErrorAlert(jsonResponse['message'] ?? 'Не удалось получить данные автомобиля');
      }
    } on TimeoutException {
      _showErrorAlert('Request timed out. Please check your internet connection or try again.');
    } catch (error) {
      debugPrint('Error fetching car data: $error');
      _showErrorAlert('Произошла ошибка при получении данных автомобиля.');
    } finally {
      setState(() {
        _isFetchingCarData = false;
      });
    }
  }

  void _updateCarFields(Map<String, dynamic> carData) {
    setState(() {
      _vinController.text = carData['Vin'] ?? '';
      _carBrandController.text = carData['CarBrand'] ?? '';
      _modelController.text = carData['CarModel'] ?? '';
      _yearController.text = carData['YearOfManufacture']?.toString() ?? ''; // Ensure string
      _bodyNoController.text = carData['BodyNo'] ?? '';
      _bodyTypeController.text = carData['BodyType'] ?? '';
      _chassisNoController.text = carData['ChassisNo'] ?? '';
      _engineCapacityController.text = carData['EngineCapacity']?.toString() ?? '';
      _enginePowerHpController.text = carData['EnginePowerHp']?.toString() ?? '';
      _enginePowerKwController.text = carData['EnginePowerKw']?.toString() ?? '';
      _engineTypeController.text = carData['EngineType'] ?? '';
      _maxWeightLadenController.text = carData['MaxWeightLaden']?.toString() ?? '';
      _maxWeightUnladenController.text = carData['MaxWeightUnladen']?.toString() ?? '';
      _numberOfSeatsController.text = carData['NumberOfSeats']?.toString() ?? '';
      _vehiclePassportController.text = carData['VehiclePassport'] ?? '';
      _phoneController.text = carData['Phone'] ?? '';
      _colorController.text = carData['Color'] ?? '';
      _typeController.text = carData['Type'] ?? '';
      _ownerController.text = carData['Owner'] ?? '';
    });
  }

  Future<List<Map<String, String>>> _fetchDropdownOptions(String url, String token, {Map<String, String> keyMap = const {'id': 'id', 'name': 'name'}}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic>? data = jsonResponse['content'];

        if (data == null) {
          debugPrint('No content found for $url');
          return [];
        }

        return data
            .map((item) => {
          'id': item[keyMap['id']]?.toString() ?? '',
          'name': item[keyMap['name']]?.toString() ?? item['type']?.toString() ?? 'N/A',
        })
            .toList();
      } else {
        debugPrint('Failed to load dropdown options: ${response.statusCode}');
        return [];
      }
    } on TimeoutException {
      debugPrint('Request timeout for $url');
      return [];
    } on Exception catch (e) {
      debugPrint('Error fetching dropdown options: $e');
      return [];
    }
  }

  /// Submits the car data to the API.
  Future<void> _submitCar() async {
    // Form validation
    if (_selectedTransportViewID == null ||
        _selectedTransportTypeID == null ||
        _selectedTransportBrandID == null ||
        _selectedTransportFuelID == null ||
        _selectedTransportOwnershipID == null ||
        _selectedTransportOwnerTypeID == null) {
      _showErrorAlert('Пожалуйста, заполните все обязательные поля');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final url = Uri.parse('$apiUrl/transport/');
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        "transportViewID": _selectedTransportViewID,
        "transportTypeID": _selectedTransportTypeID,
        "imeiGpsTracker": _imeiGpsTrackerController.text,
        "simGpsTracker": _simGpsTrackerController.text,
        "transportOwnerShipID": _selectedTransportOwnershipID,
        "transportOwnerTypeID": _selectedTransportOwnerTypeID,
        "LicensePlate": _carNumberController.text,
        "BodyNo": _bodyNoController.text,
        "BodyType": _bodyTypeController.text,
        "CarBrand": _carBrandController.text,
        "CarModel": _modelController.text,
        "ChassisNo": _chassisNoController.text,
        "RegistrationCertificateSeries": _registrationCertificateSeriesController.text,
        "EngineCapacity": _engineCapacityController.text,
        "EnginePowerHp": _enginePowerHpController.text,
        "EnginePowerKw": _enginePowerKwController.text,
        "EngineType": _engineTypeController.text,
        "MaxWeightLaden": _maxWeightLadenController.text,
        "MaxWeightUnladen": _maxWeightUnladenController.text,
        "NumberOfSeats": _numberOfSeatsController.text,
        "VehiclePassport": _vehiclePassportController.text,
        "YearOfManufacture": _yearController.text,
        "Phone": _phoneController.text,
        "Vin": _vinController.text,
        "Color": _colorController.text,
        "Type": _typeController.text,
        "Owner": _ownerController.text,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 15));
      print(body);

      if (response.statusCode == 201) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final transportId = responseData['content']['id'];
        await _addTransportToUser(transportId);
        _showSuccessAlert('Машина успешно добавлена!');
        if (mounted) Navigator.pop(context); // Go back after success
      } else if (response.statusCode == 409) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        // Conflict error - VIN code not unique\
        _showErrorAlert('Конфликт: Машина с таким VIN уже существует.');
      } else {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        print(responseData['content']);
        _showErrorAlert(responseData['content'] ?? 'Ошибка при добавлении машины.');
      }

    } on TimeoutException {
      _showErrorAlert('Request timed out. Please check your internet connection or try again.');
    } catch (error) {
      debugPrint('Error submitting car: $error');
      _showErrorAlert('Произошла непредвиденная ошибка при добавлении машины.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Adds the newly created transport to the user's profile.
  Future<void> _addTransportToUser(String transportId) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    String? baseApiUrl;
    // Determine the API URL based on globalUserType
    switch (globalUserType) {
      case 1: // Individual
        baseApiUrl = '$apiUrl/individual/$globalUserId/transport?transportId=$transportId';
        break;
      case 3: // Entrepreneur
        baseApiUrl = '$apiUrl/entrepreneur/transport?transportId=$transportId';
        break;
      case 2: // Company
        baseApiUrl = '$apiUrl/company/transport?transportId=$transportId';
        break;
      case 0: // Special handling for type 0, likely for initial setup
        final String accountType = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('accountType') ?? 'private');

        print(globalUserId);
        print(transportId);
        if (accountType == 'private') {
          debugPrint("Private account selected");
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PrivateAccountPage()));
          }
        } else if (accountType == 'business') {
          debugPrint("Business account selected");
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BusinessPage()));
          }
        }
        return; // Prevent further execution
      default:
        debugPrint("Invalid user type: $globalUserType");
        _showErrorAlert("Неверный тип пользователя.");
        return;
    }

    if (baseApiUrl == null) {
      _showErrorAlert("Не удалось определить URL для добавления транспорта к пользователю.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(baseApiUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        debugPrint("Transport added to user successfully");
      } else {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        debugPrint("Failed to add transport to user: ${response.body}");
        _showErrorAlert(responseData['message'] ?? "Ошибка при привязке машины к профилю.");
      }
    } on TimeoutException {
      _showErrorAlert('Request to add transport to user timed out.');
    } catch (error) {
      debugPrint("Error during adding transport to user: $error");
      _showErrorAlert("Произошла непредвиденная ошибка при привязке машины к профилю.");
    }
  }

  /// Retrieves the authentication token from shared preferences.
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Displays a success alert dialog.
  void _showSuccessAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Успех'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays an error alert dialog.
  void _showErrorAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          color: readOnly ? Colors.grey.shade600 : Colors.black87,
          fontSize: 16.0,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16.0,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 18.0,
          ),
          border: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(color: Colors.grey.shade400),
          focusedBorder: _outlineInputBorder(
            color: Colors.blueAccent,
            width: 2.0,
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
        cursorColor: Colors.blueAccent,
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder({
    Color color = Colors.grey,
    double width = 1.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  /// Builds a dropdown with search functionality.
  Widget _buildDropdownWithSearch(
      String label,
      List<Map<String, String>> options,
      String? selectedValue,
      ValueChanged<String?>? onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, // Smaller label for consistency
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          SearchChoices.single(
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option['id'],
                child: Text(
                  option['name'] ?? 'N/A',
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            value: selectedValue,
            hint: Text(
              "Выберите $label",
              style: const TextStyle(color: Colors.black54),
            ),
            searchHint: Text(
              "Искать $label",
              style: const TextStyle(color: Colors.black54),
            ),
            onChanged: onChanged,
            isExpanded: true,
            displayClearIcon: false,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            menuBackgroundColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
            searchFn: (String keyword, List<DropdownMenuItem<String>> items) {
              final lowerCaseKeyword = keyword.toLowerCase();
              final List<int> matchedIndexes = [];
              for (int i = 0; i < items.length; i++) {
                final itemValue = items[i].value;
                if (itemValue != null) {
                  final optionName = options.firstWhere(
                        (o) => o['id'] == itemValue,
                    orElse: () => {'name': ''}, // Provide a default if not found
                  )['name'] ?? '';
                  if (optionName.toLowerCase().contains(lowerCaseKeyword)) {
                    matchedIndexes.add(i);
                  }
                }
              }
              return matchedIndexes;
            },
            searchInputDecoration: InputDecoration(
              hintText: "Введите для поиска",
              hintStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            closeButton: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть", style: TextStyle(color: Colors.blueAccent)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Добавить машину',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading && _transportViews.isEmpty // Only show full page loader if initial dropdowns are loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children
          children: [
            // Section for fetching car data
            _buildTextField('Номер машины', _carNumberController),
            _buildTextField('Серия свидетельства о регистрации', _registrationCertificateSeriesController),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isFetchingCarData ? null : _fetchCarData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                elevation: 3,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon: _isFetchingCarData
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.search),
              label: Text(_isFetchingCarData ? 'Получение данных...' : 'Получить данные автомобиля'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // Car Details Section

            _buildTextField('Владелец', _ownerController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Телефон', _phoneController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('VIN Код', _vinController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Марка', _carBrandController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Год выпуска', _yearController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Номер кузова', _bodyNoController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Тип кузова', _bodyTypeController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Объем двигателя', _engineCapacityController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Тип двигателя', _engineTypeController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Количество мест', _numberOfSeatsController, readOnly: _isFetchingCarData),// not editable
            _buildTextField('Тип', _typeController, readOnly: _isFetchingCarData), // not editable
            _buildTextField('IMEI GPS-трекера', _imeiGpsTrackerController),// we can edit
            _buildTextField('SIM GPS-трекера', _simGpsTrackerController), // we can edit

            // Dropdowns Section
            _buildDropdownWithSearch('Вид транспорта', _transportViews, _selectedTransportViewID, (newValue) {
              setState(() {
                _selectedTransportViewID = newValue;
              });
            }),
            _buildDropdownWithSearch('Тип транспорта', _transportTypes, _selectedTransportTypeID, (newValue) {
              setState(() {
                _selectedTransportTypeID = newValue;
              });
            }),
            _buildDropdownWithSearch('Бренд транспорта', _transportBrands, _selectedTransportBrandID, (newValue) {
              setState(() {
                _selectedTransportBrandID = newValue;
              });
            }),
            _buildDropdownWithSearch('Тип топлива', _transportFuels, _selectedTransportFuelID, (newValue) {
              setState(() {
                _selectedTransportFuelID = newValue;
              });
            }),
            _buildDropdownWithSearch('Право собственности', _transportOwnerships, _selectedTransportOwnershipID, (newValue) {
              setState(() {
                _selectedTransportOwnershipID = newValue;
              });
            }),
            _buildDropdownWithSearch('Тип владельца', _transportOwnerTypes, _selectedTransportOwnerTypeID, (newValue) {
              setState(() {
                _selectedTransportOwnerTypeID = newValue;
              });
            }),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Добавить машину'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isDisabled = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label${isRequired ? ' *' : ''}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // Ensures regular font
                decoration: TextDecoration.none,
                color: isDisabled
                    ? CupertinoColors.tertiaryLabel
                    : CupertinoColors.label,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Введите $label',
              placeholderStyle: TextStyle(
                color: Colors.black,
              ),
              style: TextStyle(
                fontSize: 16,  color: Colors.black, // ← Force black text color

              ),
              enabled: !isDisabled,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              onChanged: onChanged,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.transparent, // ✅ Removes default background
              ),
            ),
          ),
        ],
      ),
    );
  }
}
