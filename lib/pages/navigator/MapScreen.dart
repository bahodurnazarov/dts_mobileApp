import 'dart:developer' as LoggingService;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NavigatorTab extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<NavigatorTab> {
  List<dynamic> gasStations = [];
  List<dynamic> parkingPlaces = [];
  bool isLoading = false;
  bool hasError = false;
  bool showStations = false;
  bool showParking = false;
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(38.5598, 68.7870);
  double _currentZoom = 13.0;

  Future<void> _fetchGasStations() async {
    LoggingService.log('Fetching gas stations...');
    if (showStations) {
      setState(() {
        showStations = false;
      });
      LoggingService.log('Hiding gas stations');
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      LoggingService.log('Making API request to getMarkerPower');
      final response = await http.get(Uri.parse('https://api.parking.dc.tj/api/v1/getMarkerPower'));

      if (response.statusCode == 200) {
        LoggingService.log('Successfully fetched gas stations data');
        final data = json.decode(response.body);
        final List<dynamic> stations = data['powers'];

        final Map<String, List<dynamic>> groupedStations = {};
        for (var station in stations) {
          final address = station['address'];
          if (!groupedStations.containsKey(address)) {
            groupedStations[address] = [];
          }
          groupedStations[address]!.add(station);
        }

        setState(() {
          gasStations = groupedStations.entries.map((entry) {
            final address = entry.key;
            final stationsAtAddress = entry.value;

            int available = 0;
            int busy = 0;
            List<dynamic> connectors = [];

            for (var station in stationsAtAddress) {
              for (var connector in station['connectors_info']) {
                if (connector['status'] == 'Available') {
                  available++;
                } else if (connector['status'] == 'Charging') {
                  busy++;
                }
                connectors.add(connector);
              }
            }

            return {
              'address': address,
              'lat': double.tryParse(stationsAtAddress.first['marker1']),
              'lng': double.tryParse(stationsAtAddress.first['marker2']),
              'available': available,
              'busy': busy,
              'connectors': connectors,
              'name': stationsAtAddress.first['name'],
              'TariffValue': stationsAtAddress.first['TariffValue'],
              'connector_capacity': stationsAtAddress.first['connector_capacity'],
              'work_schedule': stationsAtAddress.first['work_schedule'],
              'zone_name': stationsAtAddress.first['zone_name'],
            };
          }).toList();

          isLoading = false;
          showStations = true;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _fetchParkingPlaces() async {
    if (showParking) {
      setState(() {
        showParking = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('https://api.parking.dc.tj/api/v1/getMarkerParking'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['parks'] != null) {
          final List<dynamic> places = data['parks'];

          setState(() {
            parkingPlaces = places.map((park) {
              final lat = park['marker1'] != null ? double.tryParse(park['marker1'].toString()) : 0.0;
              final lng = park['marker2'] != null ? double.tryParse(park['marker2'].toString()) : 0.0;

              return {
                'lat': lat,
                'lng': lng,
                'address': park['address'] ?? 'Unknown address',
                'name': park['name'] ?? 'No Name',
                'work_schedule': park['work_schedule'] ?? 'Unknown',
                'tarif': park['tarif'] ?? 'N/A',
                'invalid': park['invalid'] ?? 'N/A',
                'all_place': park['all_place'] ?? '0',
                'polygon': [
                  LatLng(double.parse(park['polygon1']), double.parse(park['polygon2'])),
                  LatLng(double.parse(park['polygon3']), double.parse(park['polygon4'])),
                ],
              };
            }).toList();

            isLoading = false;
            showParking = true;
          });
        } else {
          throw Exception('Invalid data format: Missing "parks" key');
        }
      } else {
        throw Exception('Failed to load parking places: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(38.5598, 68.7870), // Use initialCenter instead of center
              initialZoom: 13.0, // Use initialZoom instead of zoom
              minZoom: 5.0,
              maxZoom: 18.0,
              onMapEvent: (mapEvent) {
                setState(() {
                  _currentCenter = _mapController.camera.center;
                  _currentZoom = _mapController.camera.zoom;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: ['a', 'b', 'c'],
                retinaMode: RetinaMode.isHighDensity(context), // Call the method with context
                userAgentPackageName: 'com.mintras.dts', // Recommended for production
              ),
              if (showParking && !isLoading && !hasError)
                PolygonLayer(
                  polygons: parkingPlaces.map<Polygon>((place) {
                    return Polygon(
                      points: place['polygon'],
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 6,
                    );
                  }).toList(),
                ),
              if (showParking && !isLoading && !hasError)
                MarkerLayer(
                  markers: parkingPlaces.map((place) {
                    final lat = place['lat'];
                    final lng = place['lng'];

                    if (lat != null && lng != null) {
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 30.0,
                        height: 30.0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => _buildParkingDialog(place),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_parking,
                              color: Colors.blue,
                              size: 15,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Marker(
                        point: LatLng(0, 0),
                        child: SizedBox(),
                      );
                    }
                  }).toList(),
                ),
              if (showStations && !isLoading && !hasError)
                MarkerLayer(
                  markers: gasStations.map((station) {
                    final lat = station['lat'];
                    final lng = station['lng'];
                    final available = station['available'];
                    final busy = station['busy'];

                    if (lat != null && lng != null) {
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 80.0,
                        height: 80.0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => _buildStationDialog(station),
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.blue, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.ev_station, color: Colors.blue, size: 30),
                                Text(
                                  "$available",
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$busy",
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Marker(
                        point: LatLng(0, 0),
                        child: SizedBox(),
                      );
                    }
                  }).toList(),
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.local_parking,
                  onPressed: _fetchParkingPlaces,
                  backgroundColor: showParking ? Colors.blue : Colors.grey,
                ),
                SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.ev_station,
                  onPressed: _fetchGasStations,
                  backgroundColor: showStations ? Colors.blue : Colors.grey,
                ),
                SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.add,
                  onPressed: () {
                    final newZoom = _currentZoom + 1;
                    _mapController.move(_mapController.camera.center, newZoom);
                    setState(() {
                      _currentZoom = newZoom;
                    });
                  },
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final newZoom = _currentZoom - 1;
                    _mapController.move(_mapController.camera.center, newZoom);
                    setState(() {
                      _currentZoom = newZoom;
                    });
                  },
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (hasError)
            Center(
              child: Text(
                "Failed to load data",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(15),
        backgroundColor: backgroundColor,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildParkingDialog(Map<String, dynamic> place) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_parking, color: Colors.blue, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      place['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.location_on, "Адрес", place['address']),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.access_time, "Рабочие часы", place['work_schedule']),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.attach_money, "Тариф", place['tarif'] + ' сомони'),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.accessibility_new, "Место для инвалидов", place['invalid'] == '1' ? 'Есть' : 'Нет'),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.place, "Доступные места", place['all_place']),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  ),
                  child: Text(
                    "Закрыть",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationDialog(Map<String, dynamic> station) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.ev_station, color: Colors.blue, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      station['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.location_on, "Адрес", station['address']),
              _infoRow(Icons.bolt, "Мощность", station['connector_capacity']),
              _infoRow(Icons.attach_money, "Тариф", station['TariffValue']),
              _infoRow(Icons.access_time, "График работы", station['work_schedule']),
              _infoRow(Icons.place, "Зона", station['zone_name']),
              Divider(color: Colors.grey[300]),
              SizedBox(height: 16),
              Text(
                "Коннекторы:",
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ...station['connectors'].map<Widget>((connector) {
                return _connectorInfo(connector);
              }).toList(),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  ),
                  child: Text(
                    "Закрыть",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectorInfo(Map<String, dynamic> connector) {
    String statusText = connector['status'] == 'Available' ? 'Доступно' : 'На зарядке';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.electric_bolt, color: Colors.blue, size: 24),
          SizedBox(width: 10),
          Text(
            "Коннектор ${connector['connector_id']}: ",
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              "$statusText (${connector['charging_level']}%)",
              style: TextStyle(
                fontSize: 16,
                color: connector['status'] == 'Available' ? Colors.green : Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 10),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: NavigatorTab(),
  theme: ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
  ),
));