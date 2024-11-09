
// addAttendance.dart
import 'dart:io'; // For File operations on Android
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // For accessing file system

class addAttendance extends StatefulWidget {
  final int index;

  addAttendance({required this.index});

  @override
  _addAttendanceState createState() => _addAttendanceState();
}

class _addAttendanceState extends State<addAttendance> {
  bool _isLoading = false;

  // Function to pick and process CSV file
  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      final List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

      // Process each row (skip header)
      for (var row in csvTable.skip(1)) {
        String studentName = row[0];
        String courseName = row[1];
        int attendance = row[2];

        bool studentExists = await _checkStudentExists(studentName);
        bool courseExists = await _checkCourseExists(courseName);

        if (studentExists && courseExists) {
          await _storeAttendance(studentName, courseName, attendance);
        } else {
          String errorMsg = '';
          if (!studentExists) errorMsg += 'Student "$studentName" does not exist.\n';
          if (!courseExists) errorMsg += 'Course "$courseName" does not exist.\n';
          _showErrorMessage(errorMsg);
        }
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Attendance uploaded successfully'),
      ));
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkStudentExists(String studentName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('students')
        .where('name', isEqualTo: studentName)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<bool> _checkCourseExists(String courseName) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('semester_${widget.index + 1}_CourseData')
        .get();

    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        List<dynamic> courses = doc['courses'];
        bool courseExists = courses.any((course) => course['courseName'] == courseName);
        if (courseExists) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _storeAttendance(
      String studentName, String courseName, int attendance) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('semester_${widget.index + 1}_AttendenceData')
        .where('studentName', isEqualTo: studentName)
        .get();

    if (studentDoc.docs.isNotEmpty) {
      var docRef = studentDoc.docs.first.reference;
      await docRef.update({
        'attendance.$courseName': attendance,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('semester_${widget.index + 1}_AttendenceData')
          .add({
        'studentName': studentName,
        'attendance': {
          courseName: attendance,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1),
      appBar: AppBar(
        backgroundColor: Color(0xFFD1B48C),
        title: Text('Upload Attendance for Semester ${widget.index + 1}'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select CSV File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD1B48C),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
