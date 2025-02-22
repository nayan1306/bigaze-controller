import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/quiz_creator/quiz_create_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../quizcreatepage.dart';

class QuestionDesigner extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  QuestionDesigner({super.key});

  // Fetch exams from Firestore dynamically for the current logged-in user
  Future<List<Map<String, dynamic>>> fetchExams() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Fetch the teacher document based on the current user's email
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userDoc.docs.isEmpty) {
        throw Exception('Teacher document not found');
      }

      final teacherDocId = userDoc.docs.first.id;
      print('Teacher Document ID: $teacherDocId'); // Debug log

      // Fetch exams from the teacher's exam sub-collection
      QuerySnapshot examsSnapshot = await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .get();

      print('Exams fetched: ${examsSnapshot.docs.length}'); // Debug log

      return examsSnapshot.docs.map((doc) {
        // Debug log for each exam
        print('Exam: ${doc.id} - ${doc['examName']}');
        return {
          'examId': doc.id,
          'examName': doc['examName'] ?? 'Unnamed Exam', // Fallback if no name
          'teacherDocId': teacherDocId, // Pass teacherDocId
        };
      }).toList();
    } catch (e) {
      print('Error fetching exams: $e'); // Debug log
      throw Exception("Error fetching exams: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exam'),
        // backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Fetching data
        future: fetchExams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Debug log
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams available.'));
          } else {
            final exams = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    leading: const Icon(
                      Icons.assignment,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      exam['examName'],
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Tap to create a quiz for this exam',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      print('Exam tapped: ${exam['examName']}'); // Debug log
                      // Navigate to the Create Quiz page with the selected examId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizCreatePage(
                            examId: exam['examId'],
                            teacherDocId:
                                exam['teacherDocId'], // Pass teacherDocId
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
