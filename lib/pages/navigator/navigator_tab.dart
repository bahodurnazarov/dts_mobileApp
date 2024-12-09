import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NavigatorTab extends StatefulWidget {
  @override
  _NavigatorTabState createState() => _NavigatorTabState();
}

class _NavigatorTabState extends State<NavigatorTab> {
  // Controller to manage zoom level
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern AppBar with shadow and transparent background

      body: Stack(
        children: [
          // Map with all features
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(38.861, 71.276), // Approximate center of Tajikistan
              zoom: 6.0,
              minZoom: 4.0, // Minimum zoom level
              maxZoom: 18.0, // Maximum zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              // Optional: Add markers or custom layers here
            ],
          ),

          // Zoom controls: Stylish buttons with shadows and rounded corners
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              children: [
                // Zoom In Button
                _buildZoomButton(Icons.add),
                SizedBox(height: 10), // Space between buttons
                // Zoom Out Button
                _buildZoomButton(Icons.remove),
              ],
            ),
          ),

          // Attribution: Smaller, less intrusive at the bottom
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for zoom buttons
  Widget _buildZoomButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () {
          setState(() {
            // Control zoom level
            if (icon == Icons.add) {
              _mapController.move(
                _mapController.center,
                _mapController.zoom + 1,
              );
            } else if (icon == Icons.remove) {
              _mapController.move(
                _mapController.center,
                _mapController.zoom - 1,
              );
            }
          });
        },
      ),
    );
  }
}
