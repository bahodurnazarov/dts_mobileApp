import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.menu, color: Colors.black), // Left icon
        Spacer(), // Adds space between the icon and the text
        Text(
          'DTS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Spacer(), // Adds space between the text and the right side
      ],
    );
  }
}


