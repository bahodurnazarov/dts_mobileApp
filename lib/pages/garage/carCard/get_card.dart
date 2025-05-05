import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';

class GetCardPage extends StatefulWidget {
  final String cardId;

  const GetCardPage({Key? key, required this.cardId}) : super(key: key);

  @override
  _GetCardPageState createState() => _GetCardPageState();
}

class _GetCardPageState extends State<GetCardPage> {
  late Future<Map<String, dynamic>> cardData;

  final String flag = 'assets/tajikistan_flag.jpg';

  @override
  void initState() {
    super.initState();
    cardData = fetchCardDetails(widget.cardId);
  }

  Future<Map<String, dynamic>> fetchCardDetails(String cardId) async {
    final url = '$apiUrl/transport/$cardId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      return decodedResponse['content'];
    } else {
      throw Exception('Не удалось загрузить детали автомобиля');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о Транспорте'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: cardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'car-${widget.cardId}',
                            child: Center(
                              child: Text(
                                data['CarModel'] ?? 'Модель неизвестна',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '• ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.asset(
                                              flag,
                                              width: 26,
                                              height: 16,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const Text(
                                            'TJ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Text(
                                        data['LicensePlate'] ?? 'Неизвестный номер',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Text(
                                        ' •',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('Тип транспорта:', data['transportType']?['type'], Icons.category),
                          _buildInfoRow('Бренд:', data['transportBrand']?['name'], Icons.branding_watermark),
                          _buildInfoRow('Год выпуска:', data['year'], Icons.calendar_today),
                          _buildInfoRow('Топливо:', data['transportFuel']?['name'], Icons.local_gas_station),
                          _buildInfoRow('Вместимость (тонны):', data['capacity'], Icons.line_weight),
                          _buildInfoRow('Макс. пассажиры:', data['maxCapacity'], Icons.people),
                          _buildInfoRow('Тип владельца:', data['transportOwnerType']?['name'], Icons.person),
                          _buildInfoRow('VIN код:', data['vinCod'], Icons.qr_code),
                          const Divider(height: 30, color: Colors.blue),
                          const Text(
                            'Размеры Транспорта',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('Длина:', '${data['longth'] ?? 'N/A'} мм', Icons.straighten),
                          _buildInfoRow('Высота:', '${data['height'] ?? 'N/A'} мм', Icons.height),
                          _buildInfoRow('Вес:', '${data['weight'] ?? 'N/A'} кг', Icons.fitness_center),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _deleteCar(widget.cardId),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Удалить автомобиль',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Данные не найдены'));
          }
        },
      ),
    );
  }

  Future<void> _deleteCar(String carId) async {
    final url = '$apiUrl/transport/$carId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Автомобиль успешно удален')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: ${response.body}')),
      );
    }
  }

  Widget _buildInfoRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  value?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
