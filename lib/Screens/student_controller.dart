import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/student_controller/add_group.dart';
import 'package:examiner_bigaze/Screens/student_controller/add_mail.dart';
import 'package:examiner_bigaze/Screens/student_controller/join_notification.dart';
import 'package:examiner_bigaze/Screens/student_controller/qr_generator.dart';
import 'package:examiner_bigaze/Screens/student_controller/student_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentController extends StatefulWidget {
  const StudentController({super.key});

  @override
  State<StudentController> createState() => _StudentControllerState();
}

class _StudentControllerState extends State<StudentController> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _students = [];

  // Fetch the teacher's document ID and added students
  Future<void> _fetchStudents() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Fetch the teacher's document ID from Firestore
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;

      // Fetch the students added by the teacher
      final studentsSnapshot = await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('students')
          .get();

      setState(() {
        _students = studentsSnapshot.docs.map((doc) {
          final studentData = doc.data();
          return {
            'id': doc.id,
            'name': studentData['name'],
            'email': studentData['email'],
          };
        }).toList();
      });
    }
  }

  // Function to remove a student from the list
  void _removeStudent(Map<String, String> student) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Fetch the teacher's document ID from Firestore
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;

      // Remove the student from the teacher's students collection
      await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('students')
          .doc(student['id'])
          .delete();

      // Refresh the students list after deletion
      _fetchStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student removed successfully!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents(); // Fetch students when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    // Action for QR code button
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrCodeGenerator(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddGroup()),
                    );
                  },
                  icon: const Icon(Icons.group_add),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMail()),
                    );
                  },
                  icon: const Icon(Icons.mail),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const JoinNotification()),
                    );
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
            // Pass the _removeStudent function to StudentList
            StudentList(
              students: _students
                  .map((student) => student
                      .map((key, value) => MapEntry(key, value.toString())))
                  .toList(),
              onRemoveStudent: _removeStudent,
            ),
          ],
        ),
      ),
    );
  }
}
