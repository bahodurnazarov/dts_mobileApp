import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreens extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreens> {
  List<dynamic> gasStations = [];
  bool isLoading = false;
  bool hasError = false;
  bool showStations = false; // Controls whether to show gas stations
  final MapController _mapController = MapController();

  Future<void> _fetchGasStations() async {
    if (showStations) {
      // If stations are already shown, hide them
      setState(() {
        showStations = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('https://api.parking.dc.tj/api/v1/getMarkerPower'));

      if (response.statusCode == 200) {
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
          showStations = true; // Show gas stations on the map
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(38.5598, 68.7870),
              zoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
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
                        builder: (ctx) => GestureDetector(
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
                      return null;
                    }
                  }).whereType<Marker>().toList(),
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  onPressed: () {
                    _mapController.move(_mapController.center, _mapController.zoom + 1);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  onPressed: () {
                    _mapController.move(_mapController.center, _mapController.zoom - 1);
                  },
                  child: Icon(Icons.remove),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "charger",
                  onPressed: _fetchGasStations,
                  child: Icon(Icons.ev_station),
                  backgroundColor: showStations ? Colors.green : Colors.blue, // Change color based on state
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
                "Failed to load gas stations",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
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
              // Station Name & Icon
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

              // Station Details
              Divider(color: Colors.grey[300]),
              _infoRow(Icons.location_on, "Адрес", station['address']),
              _infoRow(Icons.bolt, "Мощность", station['connector_capacity']),
              _infoRow(Icons.attach_money, "Тариф", station['TariffValue']),
              _infoRow(Icons.access_time, "График работы", station['work_schedule']),
              _infoRow(Icons.place, "Зона", station['zone_name']),
              Divider(color: Colors.grey[300]),

              SizedBox(height: 16),

              // Connectors Section
              Text(
                "Коннекторы:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ...station['connectors'].map<Widget>((connector) {
                return _connectorInfo(connector);
              }).toList(),

              SizedBox(height: 24),

              // Close Button
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



  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 10),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}

void main() => runApp(MaterialApp(
  home: MapScreens(), // Ensure this is a valid widget in your app
  theme: ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue, // Using a swatch for better theming
  ),
));