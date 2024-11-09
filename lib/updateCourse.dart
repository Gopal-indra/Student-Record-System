
// updateCourse.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCourse extends StatefulWidget {
  final int index; // Index for the semester

  UpdateCourse({required this.index});

  @override
  _UpdateCourseState createState() => _UpdateCourseState();
}

class _UpdateCourseState extends State<UpdateCourse> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseCodeController = TextEditingController();
  bool _courseExists = false;
  bool _isLoading = false;
  String? _startDate;
  String? _endDate;
  String? _courseInstructor; // Define course instructor
  String? _totalClasses; // Define total classes

  Map<String, dynamic>? courseDetails;
  DocumentSnapshot? documentSnapshot; // Store the document snapshot to update later

  // Define a regex pattern for DD/MM/YYYY format
  final RegExp _dateRegExp = RegExp(
    r"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/[0-9]{4}$",
  );

  void _checkCourseExists() async {
    setState(() {
      _isLoading = true;
      _courseExists = false;
    });

    try {
      // Query the Firestore collection for the specified semester
      var query = await FirebaseFirestore.instance
          .collection('semester_${widget.index + 1}_CourseData')
          .get();

      if (query.docs.isNotEmpty) {
        // Loop through the documents to find the course code
        for (var doc in query.docs) {
          var courses = doc['courses'] as List<dynamic>; // Get the courses list
          for (var course in courses) {
            if (course['courseCode'] == _courseCodeController.text) {
              setState(() {
                _courseExists = true;
                courseDetails = course; // Capture the course details
                documentSnapshot = doc; // Store the document to update later
              });
              break;
            }
          }
          if (_courseExists) break;
        }
      }

      if (!_courseExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _updateCourseDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update the specific course within the document
        List<dynamic> courses = documentSnapshot!['courses'];

        for (var course in courses) {
          if (course['courseCode'] == _courseCodeController.text) {
            course['startDate'] = _startDate;
            course['endDate'] = _endDate;
            course['courseInstructor'] = _courseInstructor;
            course['totalClasses'] = _totalClasses;
            break;
          }
        }

        await FirebaseFirestore.instance
            .collection('semester_${widget.index + 1}_CourseData')
            .doc(documentSnapshot!.id)
            .update({'courses': courses});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course details updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update course: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6E1), // Light brown color
      appBar: AppBar(
        title: Text('Update Course for Semester ${widget.index + 1}'),
        backgroundColor: Color(0xFFD1B48C),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _courseCodeController,
                decoration: InputDecoration(labelText: 'Course Code'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkCourseExists,
                child: Text('Check Course'),
              ),
              if (_isLoading) Center(child: CircularProgressIndicator()),
              if (_courseExists)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Course Start Date (DD/MM/YYYY)'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _startDate = value;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter course start date';
                        } else if (!_dateRegExp.hasMatch(value)) {
                          return 'Please enter a valid date in DD/MM/YYYY format';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Course End Date (DD/MM/YYYY)'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _endDate = value;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter course end date';
                        } else if (!_dateRegExp.hasMatch(value)) {
                          return 'Please enter a valid date in DD/MM/YYYY format';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Course Instructor'),
                      onChanged: (value) {
                        setState(() {
                          _courseInstructor = value;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Course Instructor name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Total No. of classes'),
                      onChanged: (value) {
                        setState(() {
                          _totalClasses = value;
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Total No. of classes';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateCourseDetails,
                      child: Text('Update Course Details'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
