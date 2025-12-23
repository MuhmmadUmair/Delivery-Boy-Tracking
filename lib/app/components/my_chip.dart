import 'package:flutter/material.dart';

class MyChip extends StatelessWidget {
  final String text;
  final Color color;
  final bool isSelected;

  const MyChip({
    super.key,
    required this.text,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color,
      label: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          strokeAlign: 1,
          color: isSelected ? Colors.amber : Color(0xff2A2A2A),
          width: 1.2,
        ),
      ),
    );
  }
}
