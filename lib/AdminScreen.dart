

// AdminScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AddStudentScreen.dart';
import 'StudentsScreen.dart';
import 'AdminCourseScreen.dart';
import 'adminAttendenceScreen.dart';

class AdminScreen extends StatefulWidget {
  final User? user;

  AdminScreen({required this.user});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void _onGridItemTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddStudentScreen()));
    }
    else if (index==1){
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdmincourseScreen()));
    }
    else if (index==2){
      Navigator.push(context, MaterialPageRoute(builder: (context) => adminAttendenceScreen()));
    }
    else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1), // Background color
      appBar: AppBar(
        backgroundColor: Color(0xFFD1B48C), // Brownish color
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.black,
            onPressed: () {
              // Handle logout action
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Color(0xFFD1B48C), // Brownish color
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.user?.photoURL ?? 'https://via.placeholder.com/150'), // User's photo URL or placeholder image
                  radius: 30,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.user?.displayName ?? 'No Name', // User's display name or default text
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(widget.user?.email ?? '', style: TextStyle(color: Colors.black)),
                    Text('Department: Admin', style: TextStyle(color: Colors.black)),
                    Text('Role: Administrator', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Color(0xFFD1B48C),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to CURAJ Engineering',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildGridItem(Icons.person_add, 'Add Student', 0),
                  _buildGridItem(Icons.book, 'Course', 1),
                  _buildGridItem(Icons.calendar_today, 'Attendence', 2),
                  _buildGridItem(Icons.list, 'Students List', 3),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFD1B48C),
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
        currentIndex: 1,
        selectedItemColor: Colors.black,
        onTap: (index) {
          // Handle bottom navigation item tap
        },
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
