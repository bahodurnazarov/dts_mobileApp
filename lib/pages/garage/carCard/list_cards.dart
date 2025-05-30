import 'package:flutter/material.dart';

import 'add_card.dart';
import 'car_card.dart';

class CardListPage extends StatelessWidget {
  final List<Map<String, dynamic>> carData;
  final String flag;

  const CardListPage({
    required this.carData,
    required this.flag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Make back icon black
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Text(
          'Все автомобили(${carData.length})',
          style: TextStyle(color: Colors.black), // Make title text black
        ),
        backgroundColor: Colors.white, // Set background color to white
        elevation: 0, // Optional: remove shadow for flat look
      ),


      body: Stack(
        children: [
          ListView.builder(
            itemCount: carData.length,
            itemBuilder: (context, index) {
              return CarCard(
                carData: carData[index],
                flag: flag,
              );
            },
          ),

          Positioned(
            bottom: 40.0, // Space from the bottom
            left: 16.0,   // Space from the left
            right: 16.0,  // Space from the right
            child: InkWell(
              onTap: () {
                // Action when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCarPage()), // Navigating to AddCarCard
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: Offset(0, 4),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Добавить машину',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
