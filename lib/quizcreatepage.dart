import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMarksController = TextEditingController();
  final _timeLimitController = TextEditingController();

  List<Map<String, dynamic>> questions = [];

  // Add a new question
  void addQuestion() {
    setState(() {
      questions.add({
        "title": "",
        "options": ["", "", "", ""],
        "answer": "",
        "marks": 0,
      });
    });
  }

  // Update a question field
  void updateQuestion(int index, String field, dynamic value) {
    setState(() {
      questions[index][field] = value;
    });
  }

  // Save quiz to Firestore
  Future<void> saveQuiz() async {
    try {
      // Add quiz to Firestore
      DocumentReference quizRef = await _firestore.collection('Quiz').add({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "maxMarks": int.parse(_maxMarksController.text),
        "createdBy": "Admin", // Replace with the actual creator
        "timeLimit": int.parse(_timeLimitController.text),
        "isPublished": true, // You can make it dynamic
        "visibility": "public", // You can make it dynamic
        "createdAt": FieldValue.serverTimestamp(),
      });

      log("Quiz added with ID: ${quizRef.id}");

      // Add questions to the 'Questions' subcollection
      for (var question in questions) {
        await _firestore
            .collection('Quiz/${quizRef.id}/Questions')
            .add(question);
        log("Question added to quiz ${quizRef.id}");
      }

      // Clear fields after saving
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _maxMarksController.clear();
        _timeLimitController.clear();
        questions.clear();
      });

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz added successfully!')),
      );
    } catch (e) {
      log("Error saving quiz: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add quiz')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _maxMarksController,
                decoration: const InputDecoration(
                  labelText: 'Max Marks',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (in minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Add Questions
              const Text('Questions:'),
              ...List.generate(questions.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Question Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "title", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(4, (optIndex) {
                      return TextField(
                        decoration: InputDecoration(
                          labelText: 'Option ${optIndex + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          updateQuestion(index, "options", [
                            ...questions[index]["options"]..[optIndex] = value
                          ]);
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "answer", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(
                        text: questions[index]["marks"].toString(),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        updateQuestion(index, "marks", int.parse(value));
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: addQuestion,
                child: const Text('Add Question'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveQuiz,
                child: const Text('Save Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
