
// showAttendence.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowAttendance extends StatefulWidget {
  final String email; // The email of the student

  ShowAttendance({required this.email});

  @override
  _ShowAttendanceState createState() => _ShowAttendanceState();
}

class _ShowAttendanceState extends State<ShowAttendance> {
  bool isLoading = true;
  List<Map<String, dynamic>> attendanceData = [];
  String? semester;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
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

        // Fetch attendance data for the student from the respective semester collection
        QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
            .collection('semester_${semester}_AttendenceData')
            .where('studentName', isEqualTo: studentData['name']) // Match by student name
            .get();

        if (attendanceSnapshot.docs.isNotEmpty) {
          setState(() {
            attendanceData = attendanceSnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['lastUpdated'] = doc['timestamp'] ?? Timestamp.now(); // Handle last updated timestamp
              return data;
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
      print("Error fetching attendance data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.brown.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : attendanceData.isEmpty
          ? Center(child: Text('No attendance data found'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Course')),
            DataColumn(label: Text('Attendance')),
            DataColumn(label: Text('Total Classes')),
            DataColumn(label: Text('Last Updated')),
          ],
          rows: _buildDataRows(),
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];

    // Iterate through the attendance data
    for (var data in attendanceData) {
      Map<String, dynamic> attendanceMap = data['attendance'] as Map<String, dynamic>;

      // Iterate through each course in the attendance map
      attendanceMap.forEach((courseName, attendance) {
        rows.add(
          DataRow(
            cells: <DataCell>[
              DataCell(Text(courseName)), // Course name
              DataCell(Text(attendance.toString())), // Attendance value
              DataCell(Text('20')), // Assuming 20 as total classes for demo (adjust accordingly)
              DataCell(Text(_formatTimestamp(data['lastUpdated']))), // Last updated
            ],
          ),
        );
      });
    }

    return rows;
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}
