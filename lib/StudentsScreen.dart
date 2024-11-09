
// StudentsScreen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1),
      appBar: AppBar(
        title: Text('Students'),
        backgroundColor: Color(0xFFD1B48C), // Brownish color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var students = snapshot.data?.docs ?? [];

          if (students.isEmpty) {
            return Center(child: Text('No students found'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index].data() as Map<String, dynamic>?;

              if (student == null || !student.containsKey('enrollment')) {
                return ListTile(
                  title: Text('Missing enrollment data'),
                );
              }

              String enrollment = student['enrollment'] ?? 'N/A';
              String name = student['name'] ?? 'No Name';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle student button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD1B48C), // Brownish color
                    foregroundColor: Colors.black,
                  ),
                  child: Text('$name - Enrollment: $enrollment'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
