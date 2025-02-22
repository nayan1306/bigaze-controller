import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/exam_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExamControllerScreen extends StatefulWidget {
  const ExamControllerScreen({super.key});

  @override
  State<ExamControllerScreen> createState() => _ExamControllerScreenState();
}

class _ExamControllerScreenState extends State<ExamControllerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to fetch the live exam
  Stream<DocumentSnapshot?> getLiveExamStream() async* {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Get the teacher's document ID
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;

      // Stream the live exam
      yield* _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .where('isLive', isEqualTo: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
    }
  }

  // Method to stop the live exam
  Future<void> stopLiveExam(String teacherDocId, String examId) async {
    try {
      await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .doc(examId)
          .update({'isLive': false});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam stopped successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping exam: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: StreamBuilder<DocumentSnapshot?>(
        stream: getLiveExamStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If no live exam, navigate to TestListPage
          if (!snapshot.hasData || snapshot.data == null) {
            return const ExamListPage(); // Display the test list page
          }

          // If live exam is found, show its details
          final examDoc = snapshot.data!;
          final examData = examDoc.data() as Map<String, dynamic>;
          final liveExamName =
              examData['examName'] ?? 'Live exam name unavailable';
          final teacherDocId = examDoc.reference.parent.parent!.id;

          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      " $liveExamName",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                      maxLines: 1,
                    ),
                    Image.asset('./assets/icon/live.gif', width: w * 0.2),
                    SizedBox(
                      width: w * 0.1,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        stopLiveExam(teacherDocId, examDoc.id);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(
                            6), // Removes padding around the text
                        minimumSize:
                            const Size(0, 0), // Ensures no minimum size
                      ),
                      child: const Text(
                        'STOP',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16, // Adjust font size if needed
                        ),
                      ),
                    ),
                  ],
                ),

                // Add any additional UI here

                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Student Proctor tiles"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
