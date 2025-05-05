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


    // Generate a random index to pick a car image

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
          width: double.infinity, // Take up full width
          height: 220.0, // Set a fixed height for the card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white], // Shades of white
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Softer shadow
                blurRadius: 12, // Smaller blur for inner shadow feel
                offset: const Offset(4, 4), // Slightly subtle offset
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Additional light shadow
                blurRadius: 20, // Wider blur for ambient shadow
                offset: const Offset(-4, -4), // Opposite direction for balance
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background image from the random selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),  // Top left corner radius
                    topRight: Radius.circular(20), // Top right corner radius
                  ),
                  child: Image.asset(
                    randomCarImage,
                    fit: BoxFit.cover,
                    height: 140.0, // Reduced height for the image
                    width: double.infinity,
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 100),
                    // Car Number with Flag
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                          border: Border.all(
                            color: Colors.black, // Border color
                            width: 1, // Border width
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), // Shadow color
                              blurRadius: 8, // Shadow blur radius
                              offset: const Offset(0, 4), // Shadow offset
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Take only the necessary space
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Dots and Flag with Country Abbreviation
                            Row(
                              children: [
                                const Text(
                                  '• ', // Starting dot before the flag
                                  style: TextStyle(
                                    fontSize: 16, // Size of the dot
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4), // Smooth edges
                                      child: Image.asset(
                                        flag,
                                        width: 26,
                                        height: 16,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Country abbreviation under the flag
                                    const Text(
                                      'TJ',
                                      style: TextStyle(
                                        fontSize: 12, // Smaller font size for country abbreviation
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Car Number with Ending Dot
                            Row(
                              children: [
                                Text(
                                  carNumber,
                                  style: const TextStyle(
                                    fontSize: 28, // Car number font size
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  ' •', // Ending dot after the car number
                                  style: TextStyle(
                                    fontSize: 16, // Size of the dot
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
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
