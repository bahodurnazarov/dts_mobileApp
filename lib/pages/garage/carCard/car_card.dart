import 'package:flutter/material.dart';
import 'dart:math';

import 'get_card.dart'; // For generating random numbers

class CarCard extends StatelessWidget {
  final String flag; // Path to the flag image
  final Map<String, dynamic> carData;

   CarCard({
    required this.flag,
    required this.carData,
  });

  // List of car images to choose from
  List<String> carImages = [
    'assets/car_images/bwm.jpg',
    'assets/car_images/porsh.jpg',
    'assets/car_images/electric.jpg',
    'assets/car_images/unknown1.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final String name = carData['CarModel'] ?? 'Unknown Model';
    final String carNumber = carData['LicensePlate'] ?? 'Unknown Number';
    final String transportType = carData['transportType']?['type'] ?? 'Unknown Type';
    final String carId = carData['id'] ?? '';

    final randomIndex = Random().nextInt(carImages.length);
    final randomCarImage = carImages[randomIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GetCardPage(cardId: carId),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 220.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    randomCarImage,
                    fit: BoxFit.cover,
                    height: 140.0,
                    width: double.infinity,
                  ),
                ),
              ),

              // Car name (top left)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 60, // Limit height to prevent pushing content too far
                  ),
                  child: Text(
                    name,
                    maxLines: 2, // Allow up to 2 lines
                    overflow: TextOverflow.ellipsis, // Show ... if still too long
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Car number plate (centered)
              Positioned.fill(
                top: 140, // Position below the image
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
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
                          mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 8),
                        Text(
                          carNumber,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
