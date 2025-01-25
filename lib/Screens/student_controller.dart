import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/student_controller/add_group.dart';
import 'package:examiner_bigaze/Screens/student_controller/qr_generator.dart';
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
            'class': studentData['class'],
          };
        }).toList();
      });
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
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    // Action for QR code button
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QrCodeGenerator()),
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
                  onPressed: () {},
                  icon: const Icon(Icons.mail),
                ),
                IconButton(
                  onPressed: () {
                    // Action for person add button
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(student['name'] ?? 'No Name'),
                            subtitle: Text(student['email'] ?? 'No Email'),
                            tileColor: const Color.fromARGB(255, 42, 42, 42),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
