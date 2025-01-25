import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatefulWidget {
  final String examId; // Accept the examId

  const CreateQuizPage({super.key, required this.examId});

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers for quiz
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMarksController = TextEditingController();
  final _timeLimitController = TextEditingController();

  List<Map<String, dynamic>> questions = [];

  // Add a new question
  void addQuestion() {
    setState(() {
      questions.add({
        "question": "",
        "options": {
          "1": "",
          "2": "",
          "3": "",
          "4": "",
        },
        "answer": 0,
        "ansExplanation": "",
        "difficulty": "medium",
        "imageUrl": "",
        "isMultipleChoice": false,
        "marks": 0,
        "tags": [],
      });
    });
  }

  // Update a question field
  void updateQuestion(int index, String field, dynamic value) {
    setState(() {
      questions[index][field] = value;
    });
  }

  // Update options for a question
  void updateOption(int questionIndex, String optionKey, String value) {
    setState(() {
      questions[questionIndex]["options"][optionKey] = value;
    });
  }

  // Save quiz to Firestore
  Future<void> saveQuiz() async {
    try {
      // Add quiz data to Firestore (under the selected exam)
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc('yourTeacherDocId')
          .collection('exams')
          .doc(widget.examId);

      // Add questions to the 'questions' sub-collection
      for (var question in questions) {
        await examRef.collection('questions').add(question);
        log("Question added to exam ${widget.examId}");
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
        const SnackBar(content: Text('Questions added successfully!')),
      );
    } catch (e) {
      log("Error saving quiz: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add questions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Questions to Quiz')),
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
              // Add Questions Section
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
                        updateQuestion(index, "question", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    ...questions[index]["options"].keys.map((key) {
                      return TextField(
                        decoration: InputDecoration(
                          labelText: 'Option $key',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          updateOption(index, key, value);
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer (Option Number)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        updateQuestion(index, "answer", int.parse(value));
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Answer Explanation',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "ansExplanation", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Difficulty (easy, medium, hard)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "difficulty", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "imageUrl", value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Marks',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        updateQuestion(index, "marks", int.parse(value));
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        updateQuestion(index, "tags",
                            value.split(',').map((tag) => tag.trim()).toList());
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
