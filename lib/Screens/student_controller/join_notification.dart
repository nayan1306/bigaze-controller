import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinNotification extends StatefulWidget {
  const JoinNotification({super.key});

  @override
  State<JoinNotification> createState() => _JoinNotificationState();
}

class _JoinNotificationState extends State<JoinNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _joinRequests = [];

  // Fetch join requests from Firestore
  Future<void> _fetchJoinRequests() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Fetch the teacher's document ID
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;

      // Fetch join requests from the joinNotification subcollection
      final joinNotificationsSnapshot = await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('notifications')
          .doc('joinNotification')
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _joinRequests = joinNotificationsSnapshot.docs.map((doc) {
          final requestData = doc.data();
          return {
            'id': doc.id,
            'studentId': requestData['studentId'],
            'studentName': requestData['studentName'],
            'studentEmail': requestData['studentEmail'],
            'status': requestData['status'],
          };
        }).toList();
      });
    }
  }

  // Accept or decline a join request
  Future<void> _updateRequestStatus(String requestId, String status) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Fetch the teacher's document ID
    final userDoc = await _firestore
        .collection('teacher')
        .where('email', isEqualTo: currentUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final teacherDocId = userDoc.docs.first.id;

      // Update the status of the join request
      await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('notifications')
          .doc('joinNotification')
          .collection('requests')
          .doc(requestId)
          .update({'status': status});

      // Refresh the requests list after updating the status
      _fetchJoinRequests();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJoinRequests(); // Fetch the join requests when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
      ),
      body: _joinRequests.isEmpty
          ? const Center(child: Text('No join requests'))
          : ListView.builder(
              itemCount: _joinRequests.length,
              itemBuilder: (context, index) {
                final request = _joinRequests[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(request['studentName']),
                    subtitle: Text(request['studentEmail']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            _updateRequestStatus(request['id'], 'accepted');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _updateRequestStatus(request['id'], 'declined');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
