
// showCourse.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowCourse extends StatefulWidget {
  final String email; // The email of the student

  ShowCourse({required this.email});

  @override
  _ShowCourseState createState() => _ShowCourseState();
}

class _ShowCourseState extends State<ShowCourse> {
  bool isLoading = true;
  List<Map<String, dynamic>> courseData = [];
  String? semester;

  @override
  void initState() {
    super.initState();
    _fetchCourseData();
  }

  Future<void> _fetchCourseData() async {
    try {
      // Fetch student data to get the semester
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        var studentData = studentSnapshot.docs.first.data() as Map<String, dynamic>;
        semester = studentData['semester']; // Get semester of the student

        // Fetch course data for the student's semester
        QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
            .collection('semester_${semester}_CourseData')
            .get();

        if (courseSnapshot.docs.isNotEmpty) {
          setState(() {
            // Assuming 'courses' is an array containing course details in each document
            courseData = courseSnapshot.docs.expand((doc) {
              List<dynamic> courses = doc['courses'];
              return courses.map((course) => course as Map<String, dynamic>);
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching course data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        backgroundColor: Colors.brown.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : courseData.isEmpty
          ? Center(child: Text('No course data found'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Course Name')),
            DataColumn(label: Text('Course Code')),
            DataColumn(label: Text('Start Date')),
            DataColumn(label: Text('End Date')),
            DataColumn(label: Text('Credits')),
            DataColumn(label: Text('Total Classes')),
            DataColumn(label: Text('Instructor')),
          ],
          rows: courseData.map((data) {
            return DataRow(
              cells: <DataCell>[
                DataCell(Text(data['courseName'] ?? 'N/A')), // Course name as String
                DataCell(Text(data['courseCode'] ?? 'N/A')), // Course code as String
                DataCell(Text(data['startDate'] ?? 'N/A')), // Start date as String
                DataCell(Text(data['endDate'] ?? 'N/A')), // End date as String
                DataCell(Text(data['credit'] ?? 'N/A')), // Credits as String
                DataCell(Text(data['totalClasses'] ?? 'N/A')), // Total classes as String
                DataCell(Text(data['courseInstructor'] ?? 'N/A')), // Instructor as String
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
