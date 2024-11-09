
// StudentScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minor_project/showCourse.dart';
import 'LoginPage.dart';
import 'showAttendence.dart'; // Import ShowAttendance screen

class StudentScreen extends StatefulWidget {
  final String email;

  StudentScreen({required this.email});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          studentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching student data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade100,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.black,
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentData == null
          ? Center(child: Text('No student data found'))
          : SafeArea(
        child: Column(
          children: [
            // Profile Section
            Container(
              color: Colors.brown.shade100,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_picture.png'), // Add your profile image in assets
                    radius: 30.0,
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentData!['name'] ?? 'Student Name',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        studentData!['enrollment'] ?? 'Enrollment Number',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          Text('Department: ${studentData!['department'] ?? 'CSE'}'),
                          SizedBox(width: 20.0),
                          Text('Semester: ${studentData!['semester'] ?? 'VI'}'),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.notifications),
                  Icon(Icons.menu),
                ],
              ),
            ),
            // Welcome Section
            Container(
              color: Colors.brown.shade300,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Buttons Section
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16.0),
                children: [
                  buildMenuButton(Icons.calendar_today, 'Attendance'), // Attendance button
                  buildMenuButton(Icons.book, 'Course'),
                  buildMenuButton(Icons.person, 'Faculty'),
                  buildMenuButton(Icons.more_horiz, 'Other'),
                ],
              ),
            ),
            // Bottom Navigation Bar
            BottomNavigationBar(
              backgroundColor: Colors.brown.shade100,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inbox),
                  label: 'Inbox',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each menu button
  Widget buildMenuButton(IconData icon, String label) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (label == 'Attendance') {
            // Navigate to ShowAttendance screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowAttendance(email: widget.email),
              ),
            );

          }
          if (label == 'Course') {
            // Navigate to ShowAttendance screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowCourse(email: widget.email),
              ),
            );

          }
          else {
            // Handle other buttons
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0),
            SizedBox(height: 10.0),
            Text(
              label,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
