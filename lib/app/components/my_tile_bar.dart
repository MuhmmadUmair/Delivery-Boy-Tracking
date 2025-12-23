import 'package:flutter/material.dart';

class MyTileBar extends StatelessWidget {
  final IconData icon;
  final String num;
  final String type;
  const MyTileBar({
    super.key,
    required this.icon,
    required this.num,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xff333333)),
        color: Color(0xff121212),
      ),
      height: 135,
      width: 130,
      child: Column(
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 50,
              width: 50,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
          SizedBox(height: 7),
          Text(
            num,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            type,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
