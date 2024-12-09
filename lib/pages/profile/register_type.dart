import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegistrationTypeSelector extends StatelessWidget {
  final int? selectedRegistrationType; // Make it nullable
  final ValueChanged<int> onValueChanged;

  RegistrationTypeSelector({
    required this.selectedRegistrationType,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title with modern typography
        Text(
          'Выберите тип пользователя',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 16),

        // Column of custom segments for registration types with descriptions
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegment(1, 'Физическое лицо', 'Индивидуальные лица, не занимающиеся предпринимательской деятельностью'),
            _buildSegment(2, 'Юридическое лицо', 'Компания или организация, имеющая юридическую личность'),
            _buildSegment(3, 'Индивидуальный предприниматель', 'Частное лицо, занимающееся бизнесом от своего имени'),
          ],
        ),
      ],
    );
  }

  // Custom segment with background color change when selected and description
  Widget _buildSegment(int value, String label, String description) {
    bool isSelected = value == selectedRegistrationType;

    return GestureDetector(
      onTap: () {
        onValueChanged(value); // Call the callback when a segment is tapped
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: EdgeInsets.only(bottom: 16), // Space between segments
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16, // Slightly larger font size for labels
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87, // White when selected
              ),
            ),
            SizedBox(height: 8), // Space between label and description
            Text(
              description,
              style: TextStyle(
                fontSize: 12, // Smaller font size for description
                fontWeight: FontWeight.w400,
                color: isSelected ? Colors.white70 : Colors.black54, // Lighter text for description
              ),
            ),
          ],
        ),
      ),
    );
  }
}
