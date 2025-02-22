import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  _ExamListPageState createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Fetch exam entries from the "exams" sub-collection
  Stream<QuerySnapshot> fetchExamEntries() async* {
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
      yield* _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .snapshots();
    }
  }

  // Function to update the isLive status of an exam in Firestore
  Future<void> updateIsLiveStatus(String examId, bool isLiveStatus) async {
    try {
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

        // Update the isLive field
        await _firestore
            .collection('teacher')
            .doc(teacherDocId)
            .collection('exams')
            .doc(examId)
            .update({
          'isLive': isLiveStatus,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam status updated!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating exam status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchExamEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exams found.'));
          }

          // Data from Firestore
          var examEntries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: examEntries.length,
            itemBuilder: (context, index) {
              var examData = examEntries[index];
              String examId = examData.id;
              String examName = examData['examName'] ?? 'N/A';
              String examType = examData['examType'] ?? 'N/A';
              int duration = examData['duration'] ?? 0;
              String instructions = examData['instructions'] ?? 'N/A';
              String startAt =
                  examData['startAt']?.toDate().toString() ?? 'N/A';
              bool isLive = examData['isLive'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(examName),
                  subtitle: Text(
                      'Type: $examType\nDuration: $duration minutes\nStart At: $startAt\nInstructions: $instructions'),
                  trailing: IconButton(
                    icon: Icon(
                      isLive ? Icons.stop : Icons.play_arrow,
                      color: isLive ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      // Toggle the isLive status
                      updateIsLiveStatus(examId, !isLive);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
