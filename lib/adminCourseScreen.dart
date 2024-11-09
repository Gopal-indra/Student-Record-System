
// adminCourseScreen.dart
import 'package:flutter/material.dart';
import 'addCourse.dart';
import 'updateCourse.dart';

class AdmincourseScreen extends StatefulWidget {
  @override
  _AdmincourseScreenState createState() => _AdmincourseScreenState();
}

class _AdmincourseScreenState extends State<AdmincourseScreen> {
  void _onGridItemTapped(int index) {
    // Show a dialog with options for "Add Course" and "Update Course Details"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => addCourse(index: index)), // Navigate to add course screen
                  );
                },
                child: Text('Add Course'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Navigate to the update course details screen (you need to create this screen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateCourse(index: index)), // Assuming UpdateCourseScreen exists
                  );
                },
                child: Text('Update Course Details'),
              ),
            ],
          ),
        );
      },
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
