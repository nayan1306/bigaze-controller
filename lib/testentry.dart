import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TestEntryPage extends StatefulWidget {
  const TestEntryPage({super.key});

  @override
  _TestEntryPageState createState() => _TestEntryPageState();
}

class _TestEntryPageState extends State<TestEntryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController startAtController = TextEditingController();

  bool isLive = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Function to add exam data to Firestore
  Future<void> addExamData() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No teacher profile found!')),
        );
        return;
      }

      // Get the teacher's document ID
      final teacherDocId = userDoc.docs.first.id;

      // Add the exam data to the "exams" sub-collection
      await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .add({
        'examName': nameController.text,
        'examType': typeController.text,
        'duration': int.tryParse(durationController.text) ?? 0,
        'instructions': instructionsController.text,
        'startAt': Timestamp.fromDate(DateTime.parse(
            startAtController.text)), // Convert to Firestore Timestamp
        'isLive': isLive, // Include isLive field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding exam data: $e')),
      );
    }
  }

  // Function to show the date and time picker
  Future<void> selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (selectedTime != null) {
        final combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        startAtController.text = combinedDateTime.toIso8601String();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exam Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Exam Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (in minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: startAtController,
              decoration: const InputDecoration(
                labelText: 'Start At (YYYY-MM-DDTHH:MM:SS)',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: selectDateTime,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Is Live:'),
                Checkbox(
                  value: isLive,
                  onChanged: (bool? value) {
                    setState(() {
                      isLive = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addExamData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
