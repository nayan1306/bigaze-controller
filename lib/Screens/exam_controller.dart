import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/testlist.dart';
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
            return const TestListPage(); // Display the test list page
          }

          // If live exam is found, show its details
          final examData = snapshot.data!.data() as Map<String, dynamic>;
          final liveExamName =
              examData['examName'] ?? 'Live exam name unavailable';

          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.04),
                Row(
                  children: [
                    Text(
                      " $liveExamName",
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                      maxLines: 1,
                    ),
                    Image.asset('./assets/icon/ilve.gif', width: w * 0.2),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
