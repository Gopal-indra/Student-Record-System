
// adminAttendenceScreen.dart

import 'package:flutter/material.dart';
import 'addAttendence.dart';

class adminAttendenceScreen extends StatefulWidget {
  @override
  _adminAttendenceScreenState createState() => _adminAttendenceScreenState();
}

class _adminAttendenceScreenState extends State<adminAttendenceScreen> {
  void _onGridItemTapped(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => addAttendance(index: index)), // Passing index as argument
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1), // Background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGridItem(Icons.book, 'Semester I', 0),
            _buildGridItem(Icons.book, 'Semester II', 1),
            _buildGridItem(Icons.book, 'Semester III', 2),
            _buildGridItem(Icons.book, 'Semester IV', 3),
            _buildGridItem(Icons.book, 'Semester V', 4),
            _buildGridItem(Icons.book, 'Semester VI', 5),
            _buildGridItem(Icons.book, 'Semester VII', 6),
            _buildGridItem(Icons.book, 'Semester VIII', 7),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () => _onGridItemTapped(index),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFD1B48C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
