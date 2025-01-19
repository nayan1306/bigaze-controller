import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestEntryPage extends StatefulWidget {
  const TestEntryPage({super.key});

  @override
  _TestEntryPageState createState() => _TestEntryPageState();
}

class _TestEntryPageState extends State<TestEntryPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();

  bool testStart = false;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add data to Firestore
  Future<void> addTestData() async {
    try {
      await _firestore.collection('examiner').add({
        'testdescription': descriptionController.text,
        'testname': nameController.text,
        'testschedule':
            Timestamp.fromDate(DateTime.parse(scheduleController.text)),
        'teststart': testStart,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test data added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding test data: $e')),
      );
    }
  }

  // Function to show the date and time picker
  Future<void> selectDateTime() async {
    // Date Picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Time Picker
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (selectedTime != null) {
        // Combine date and time into a single string
        final DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Update the schedule controller with the selected date and time
        scheduleController.text =
            combinedDateTime.toIso8601String(); // ISO 8601 format
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures layout adjusts when keyboard appears
      appBar: AppBar(
        title: const Text('Add Test Details'),
      ),
      body: SingleChildScrollView(
        // Makes the entire body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Test Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Test Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scheduleController,
              decoration: const InputDecoration(
                labelText: 'Test Schedule (YYYY-MM-DDTHH:MM:SS)',
                border: OutlineInputBorder(),
              ),
              readOnly:
                  true, // Makes the text field read-only since we use a picker
              onTap: selectDateTime, // Trigger date and time picker when tapped
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Test Started:'),
                Checkbox(
                  value: testStart,
                  onChanged: (bool? value) {
                    setState(() {
                      testStart = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addTestData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
