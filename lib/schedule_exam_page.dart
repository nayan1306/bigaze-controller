import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import 'widgets/custom_submit_button.dart';

class ScheduleExamPage extends StatefulWidget {
  const ScheduleExamPage({super.key});

  @override
  _ScheduleExamPageState createState() => _ScheduleExamPageState();
}

class _ScheduleExamPageState extends State<ScheduleExamPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _startAtController = TextEditingController();

  bool _isLive = false;
  int _selectedDuration = 30; // Default duration in minutes

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _addExamData() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      _showSnackBar('No user logged in!');
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('teacher')
          .where('email', isEqualTo: currentUser.email)
          .get();

      if (userDoc.docs.isEmpty) {
        _showSnackBar('No teacher profile found!');
        return;
      }

      final teacherDocId = userDoc.docs.first.id;

      await _firestore
          .collection('teacher')
          .doc(teacherDocId)
          .collection('exams')
          .add({
        'examName': _nameController.text,
        'examType': _typeController.text,
        'duration': _selectedDuration,
        'instructions': _instructionsController.text,
        'startAt': Timestamp.fromDate(DateTime.parse(_startAtController.text)),
        'isLive': _isLive,
      });

      _showSnackBar('Exam scheduled');
      _clearForm();

      // Navigate back to the home screen after success
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error adding exam data: $e');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _instructionsController.clear();
    _startAtController.clear();
    setState(() {
      _isLive = false;
      _selectedDuration = 30;
    });
  }

  Future<void> _selectDateTime() async {
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
        _startAtController.text = combinedDateTime.toIso8601String();
      }
    }
  }

  void _showDurationPicker() {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Duration (Minutes)'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return NumberPicker(
                value: _selectedDuration,
                minValue: 1,
                maxValue: 240,
                step: 1,
                axis: Axis.vertical,
                textStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                selectedTextStyle:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                onChanged: (int value) {
                  setState(() => _selectedDuration = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.lightGreenAccent,
      ),
    );
  }

  int _getWordCount(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Schedule Exam'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Exam name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Exam Type',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Exam type is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showDurationPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration: $_selectedDuration minutes',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.timer, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  // prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Instructions are required';
                  }
                  if (_getWordCount(value) > 500) {
                    return 'Instructions cannot exceed 500 words';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Word count: ${_getWordCount(_instructionsController.text)}/500',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startAtController,
                decoration: const InputDecoration(
                  labelText: 'Start At',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _selectDateTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Start time is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Is Live:'),
                  Switch(
                    value: _isLive,
                    onChanged: (bool value) {
                      setState(() {
                        _isLive = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: _addExamData,
                text: 'Submit',
                color: const Color.fromARGB(255, 172, 255, 175),
                textColor: const Color.fromARGB(255, 67, 67, 67),
                borderRadius: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
