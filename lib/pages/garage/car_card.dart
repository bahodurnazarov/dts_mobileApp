import 'package:flutter/material.dart';

class CarCard extends StatelessWidget {
  final String flag; // Path to the flag im
  final Map<String, dynamic> carData;


  const CarCard({
    required this.flag,
    required this.carData,
  });

  // Map transport type to corresponding icon
  IconData _getTransportIcon(String transportType) {
    switch (transportType) {
      case "Самосвали":
        return Icons.directions_car;
      case "Трактор":
        return Icons.agriculture;
      case "Автогрейдер":
        return Icons.build;
      case "Таксы":
        return Icons.local_taxi;
      case "Микроавтобус":
        return Icons.directions_bus;
      case "Цистерны":
        return Icons.local_car_wash;
      case "С бортовой платформой":
        return Icons.widgets;
      default:
        return Icons.local_shipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = carData['model'];
    final String carNumber = carData['carNumber'];
    final String transportType = carData['transportType']['type'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: GestureDetector(
        onTap: () {
          print('Tapped on $name');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Faded Background Icon
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  _getTransportIcon(transportType),
                  size: 150,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Car Number with Flag
                    Row(
                      children: [
                        // Flag
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4), // Smooth edges
                          child: Image.asset(
                            flag,
                            width: 28,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Car Number
                        Text(
                          carNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Transport Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTransportIcon(transportType),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            transportType,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
