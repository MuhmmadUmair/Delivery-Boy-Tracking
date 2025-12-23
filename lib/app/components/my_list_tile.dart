import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String nameTitle;
  final String purpose;
  final String location;
  final String status;
  final String date;
  const MyListTile({
    super.key,
    required this.nameTitle,
    required this.purpose,
    required this.location,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xff333333)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xff333333),
            child: Icon(Icons.person, color: Colors.amber),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  purpose,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(height: 20),
                Text(date, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
