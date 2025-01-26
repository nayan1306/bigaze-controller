import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMail extends StatefulWidget {
  const AddMail({super.key});

  @override
  State<AddMail> createState() => _AddMailState();
}

class _AddMailState extends State<AddMail> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add email
  void _addEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email!')),
      );
      return;
    }

    // Get the current logged-in user
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Check if the email exists in the students collection
    final studentSnapshot = await _firestore
        .collection('students')
        .where('email', isEqualTo: email)
        .get();

    if (studentSnapshot.docs.isNotEmpty) {
      // Student exists, proceed to add to teacher's subcollection
      final studentDoc = studentSnapshot.docs.first;
      final studentId = studentDoc.id;
      final studentName = studentDoc['name'];

      // Get the teacher's document ID
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final teacherDocId = userDoc.docs.first.id;

        // Add the student to the teacher's subcollection
        await _firestore
            .collection('teacher')
            .doc(teacherDocId)
            .collection('students')
            .doc(studentId)
            .set({
          'name': studentName,
          'email': email,
          'studentId': studentId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student $studentName added successfully!'),
            backgroundColor: const Color.fromARGB(130, 105, 240, 175),
            duration: const Duration(milliseconds: 500),
          ),
        );
        _emailController.clear(); // Clear the input field

        // Pop the screen and go back to the previous screen
        Navigator.pop(context);
      }
    } else {
      // If student doesn't exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Student with this email does not exist!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Email input field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Enter email address',
                border: OutlineInputBorder(),
                hintText: 'example@example.com',
              ),
            ),
            const SizedBox(height: 20),
            // Add button
            Center(
              child: ElevatedButton(
                onPressed: _addEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(139, 193, 193, 193),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text(
                  'Add Email',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
