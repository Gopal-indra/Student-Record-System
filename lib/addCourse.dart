
// addCourse.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addCourse extends StatefulWidget {
  final int index; // Receive the index here

  addCourse({required this.index}); // Constructor to accept index

  @override
  _addCourseState createState() => _addCourseState();
}

class _addCourseState extends State<addCourse> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  List<Map<String, dynamic>> courses = [
    {"courseName": "", "courseCode": "", "credit": ""}
  ];

  // Function to check if semester data exists and append new courses if so
  Future<void> _addCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Check if the semester's CourseData document already exists
        QuerySnapshot existingCoursesSnapshot = await FirebaseFirestore.instance
            .collection('semester_${widget.index + 1}_CourseData')
            .get();

        if (existingCoursesSnapshot.docs.isNotEmpty) {
          // If a document already exists, append the new courses
          var docRef = existingCoursesSnapshot.docs.first.reference;
          List existingCourses = existingCoursesSnapshot.docs.first['courses'] ?? [];

          // Append new courses to the existing list
          existingCourses.addAll(courses);

          // Update the existing document with the new list of courses
          await docRef.update({
            'courses': existingCourses,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Courses updated successfully')),
          );
        } else {
          // If no document exists, create a new one
          await FirebaseFirestore.instance
              .collection('semester_${widget.index + 1}_CourseData')
              .add({
            'courses': courses, // Store the list of courses
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course added successfully')),
          );
        }

        // Reset the form
        setState(() {
          courses = [
            {"courseName": "", "courseCode": "", "credit": ""}
          ];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add course: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to add more course fields
  void _addCourseField() {
    setState(() {
      courses.add({"courseName": "", "courseCode": "", "credit": ""});
    });
  }

  // Function to remove a course field
  void _removeCourseField(int index) {
    setState(() {
      courses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1), // Light brown color
      appBar: AppBar(
        title: Text('Add Courses for Semester ${widget.index + 1}'), // Show semester number
        backgroundColor: Color(0xFFD1B48C), // Brownish color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Add course form
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Course Name'),
                          onChanged: (value) {
                            setState(() {
                              courses[index]['courseName'] = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a course name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Course Code'),
                          onChanged: (value) {
                            setState(() {
                              courses[index]['courseCode'] = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a course code';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Credit'),
                          onChanged: (value) {
                            setState(() {
                              courses[index]['credit'] = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter course credit';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (index == courses.length - 1)
                              ElevatedButton(
                                onPressed: _addCourseField,
                                child: Text('Add Another Course'),
                              ),
                            if (courses.length > 1)
                              ElevatedButton(
                                onPressed: () => _removeCourseField(index),
                                child: Text('Remove Course'),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _addCourse,
                  child: Text('Add Course'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
