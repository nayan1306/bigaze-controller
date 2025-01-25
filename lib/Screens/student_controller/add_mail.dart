import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMail extends StatefulWidget {
  const AddMail({super.key});

  @override
  State<AddMail> createState() => _AddMailState();
}

class _AddMailState extends State<AddMail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final List<Map<String, String>> _studentsToAdd =
      []; // List to store selected students
  Map<String, List<Map<String, dynamic>>> _studentsByClass =
      {}; // Grouped students by class/division

  String? teacherDocId;

  // Method to fetch the teacher's document ID
  Future<void> _fetchTeacherDocId() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Fetch teacher's document ID
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      setState(() {
        teacherDocId = userDoc.docs.first.id;
      });
    }
  }

  // Method to fetch all students and group by class
  // Method to fetch all students and group by class
  Future<void> _fetchStudents() async {
    final studentsSnapshot = await _firestore.collection('students').get();
    log('Fetched Students: ${studentsSnapshot.docs.length} students found.');

    // Group students by class
    Map<String, List<Map<String, dynamic>>> groupedStudents = {};
    for (var doc in studentsSnapshot.docs) {
      final studentData = doc.data();
      log('Student Data: ${studentData.toString()}'); // Log student data

      // Convert class to String if it's an integer
      final className =
          studentData['class'].toString(); // Ensure it's treated as String

      if (!groupedStudents.containsKey(className)) {
        groupedStudents[className] = [];
      }

      groupedStudents[className]!.add({
        'id': doc.id,
        'name': studentData['name'],
        'email': studentData['email'],
        'class': className,
      });
    }

    setState(() {
      _studentsByClass = groupedStudents;
      log('Grouped Students: $_studentsByClass'); // Log grouped students
    });
  }

  // Method to add selected students
  Future<void> _addStudents() async {
    if (_studentsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students selected!')),
      );
      return;
    }

    try {
      final collectionRef = _firestore.collection('teacher');
      final batch = _firestore.batch();

      for (var student in _studentsToAdd) {
        final docRef =
            collectionRef.doc(teacherDocId).collection('students').doc();
        batch.set(
            docRef, student); // Add students under the teacher's document ID
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Students added successfully!')),
      );

      setState(() {
        _studentsToAdd.clear(); // Clear the selected students
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding students: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeacherDocId(); // Fetch the teacher's document ID on init
    _fetchStudents(); // Fetch the students from Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Students'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Students to Add:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _studentsByClass.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _studentsByClass.keys.length,
                    itemBuilder: (context, index) {
                      final className = _studentsByClass.keys.elementAt(index);
                      final studentsInClass = _studentsByClass[className]!;

                      return ExpansionTile(
                        title: Text(
                          'Cohort : $className',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        children: studentsInClass.map((student) {
                          return ListTile(
                            title: Text(student['name'] ?? 'No Name'),
                            subtitle: Text(student['email'] ?? 'No Email'),
                            trailing: Checkbox(
                              value: _studentsToAdd
                                  .any((s) => s['id'] == student['id']),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _studentsToAdd.add({
                                      'id': student['id'],
                                      'name': student['name'],
                                      'email': student['email'],
                                      'class': student['class'],
                                    });
                                  } else {
                                    _studentsToAdd.removeWhere(
                                        (s) => s['id'] == student['id']);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _addStudents,
                  child: const Text('Add Selected Students'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
