import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xff2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
