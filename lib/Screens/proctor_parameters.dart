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

  // Controllers for the input lists
  List<TextEditingController> prohibitedObjectsControllers = [];
  List<TextEditingController> prohibitedSoundsControllers = [];

  // Fetch the existing proctor parameters from Firestore
  Future<void> fetchProctorParameters() async {
    try {
      DocumentReference proctorParametersRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId)
          .collection('proctorParameters')
          .doc('proctorParameters');

      DocumentSnapshot docSnapshot = await proctorParametersRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Set the values in the text controllers if they exist
        if (data['prohibitedObjects'] != null) {
          List<String> prohibitedObjects =
              List<String>.from(data['prohibitedObjects']);
          setState(() {
            prohibitedObjectsControllers = prohibitedObjects
                .map((e) => TextEditingController(text: e))
                .toList();
          });
        }
        if (data['prohibitedSounds'] != null) {
          List<String> prohibitedSounds =
              List<String>.from(data['prohibitedSounds']);
          setState(() {
            prohibitedSoundsControllers = prohibitedSounds
                .map((e) => TextEditingController(text: e))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching proctor parameters: $e');
    }
  }

  // Save proctor parameters to Firestore
  Future<void> saveProctorParameters() async {
    try {
      DocumentReference proctorParametersRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId)
          .collection('proctorParameters')
          .doc('proctorParameters');

      // Get the current data from the text fields
      List<String> prohibitedObjects = prohibitedObjectsControllers
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      List<String> prohibitedSounds = prohibitedSoundsControllers
          .map((e) => e.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await proctorParametersRef.set({
        'prohibitedObjects': prohibitedObjects,
        'prohibitedSounds': prohibitedSounds,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proctor parameters saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save proctor parameters')),
      );
      print('Error saving proctor parameters: $e');
    }
  }

  // Add new input field
  void addNewProhibitedObject() {
    setState(() {
      prohibitedObjectsControllers.add(TextEditingController());
    });
  }

  void addNewProhibitedSound() {
    setState(() {
      prohibitedSoundsControllers.add(TextEditingController());
    });
  }

  // Remove input field
  void removeProhibitedObject(int index) {
    setState(() {
      prohibitedObjectsControllers.removeAt(index);
    });
  }

  void removeProhibitedSound(int index) {
    setState(() {
      prohibitedSoundsControllers.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProctorParameters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proctor Parameters')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prohibited Objects:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...List.generate(prohibitedObjectsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            controller: prohibitedObjectsControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Enter prohibited object',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeProhibitedObject(index),
                      ),
                    ],
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: addNewProhibitedObject,
                icon: const Icon(Icons.add,
                    color: Color.fromARGB(255, 255, 255, 255)),
                label: const Text(
                  'Add Another Object',
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(6.0),
                  backgroundColor: const Color.fromARGB(231, 253, 157, 255),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prohibited Sounds:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...List.generate(prohibitedSoundsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            controller: prohibitedSoundsControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Enter prohibited sound',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeProhibitedSound(index),
                      ),
                    ],
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: addNewProhibitedSound,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add Another Sound',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(7.0),
                  backgroundColor: const Color.fromARGB(231, 250, 156, 255),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: saveProctorParameters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                  ),
                  child: const Text('Save Proctor Parameters',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
