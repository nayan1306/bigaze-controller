import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProctorParametersPage extends StatefulWidget {
  final String examId;
  final String teacherDocId;

  const ProctorParametersPage({
    super.key,
    required this.examId,
    required this.teacherDocId,
  });

  @override
  _ProctorParametersPageState createState() => _ProctorParametersPageState();
}

class _ProctorParametersPageState extends State<ProctorParametersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _prohibitedObjectsController =
      TextEditingController();
  final TextEditingController _prohibitedSoundsController =
      TextEditingController();

  // Save proctor parameters to Firestore
  Future<void> saveProctorParameters() async {
    try {
      // Reference to the proctorParameters document under the specific exam
      DocumentReference proctorParametersRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId)
          .collection('proctorParameters')
          .doc('proctorParameters');

      // Get the current data from the text fields
      List<String> prohibitedObjects = _prohibitedObjectsController.text
          .split(',') // Split by commas to create a list
          .map((e) => e.trim())
          .toList();
      List<String> prohibitedSounds = _prohibitedSoundsController.text
          .split(',') // Split by commas to create a list
          .map((e) => e.trim())
          .toList();

      // Set the document data
      await proctorParametersRef.set({
        'prohibitedObjects': prohibitedObjects,
        'prohibitedSounds': prohibitedSounds,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proctor parameters saved successfully!')),
      );
    } catch (e) {
      // Handle any errors that occur during saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save proctor parameters')),
      );
      print('Error saving proctor parameters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proctor Parameters')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prohibited Objects (comma separated):'),
            TextField(
              controller: _prohibitedObjectsController,
              decoration: const InputDecoration(
                labelText: 'Enter prohibited objects',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Prohibited Sounds (comma separated):'),
            TextField(
              controller: _prohibitedSoundsController,
              decoration: const InputDecoration(
                labelText: 'Enter prohibited sounds',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProctorParameters,
              child: const Text('Save Proctor Parameters'),
            ),
          ],
        ),
      ),
    );
  }
}
