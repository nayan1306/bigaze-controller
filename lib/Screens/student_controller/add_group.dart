import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddMailState();
}

class _AddMailState extends State<AddGroup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final List<Map<String, String>> _studentsToAdd = [];
  Map<String, List<Map<String, dynamic>>> _studentsByClass = {};

  String? teacherDocId;

  Future<void> _fetchTeacherDocId() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

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

  // Optimized method to fetch and group students by class
  Future<void> _fetchStudents() async {
    final studentsSnapshot = await _firestore
        .collection('students')
        .where('isActive',
            isEqualTo: true) // Optimized: Only fetch active students
        .get();

    log('Fetched Students: ${studentsSnapshot.docs.length} students found.');

    Map<String, List<Map<String, dynamic>>> groupedStudents = {};
    for (var doc in studentsSnapshot.docs) {
      final studentData = doc.data();
      log('Student Data: ${studentData.toString()}');

      final className = studentData['class'].toString();

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
      log('Grouped Students: $_studentsByClass');
    });
  }

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
        batch.set(docRef, student);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Students added successfully!')),
      );

      setState(() {
        _studentsToAdd.clear();
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
    _fetchTeacherDocId();
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Select Your Scholars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        backgroundColor: Colors.blueGrey.shade700,
                        title: Text(
                          'Cohort: $className',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        children: studentsInClass.map((student) {
                          return ListTile(
                            tileColor: Colors.blueGrey.shade800,
                            title: Text(student['name'] ?? 'No Name',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(student['email'] ?? 'No Email',
                                style: const TextStyle(color: Colors.white70)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 232, 255, 225), // Neon purple
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Add Selected Students',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
