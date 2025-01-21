import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/quiz_preview_page.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatefulWidget {
  final String examId; // Exam ID passed from ExamListPage
  final String teacherDocId; // Teacher document ID passed from ExamListPage

  const CreateQuizPage(
      {super.key, required this.examId, required this.teacherDocId});

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // Use dynamic teacherDocId passed from ExamListPage
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId) // Use dynamic teacherDocId
          .collection('exams')
          .doc(widget.examId);

      // If the exam document doesn't exist, create it (if needed)
      if (!(await examRef.get()).exists) {
        await examRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Add questions to the 'questions' sub-collection
      for (var question in questions) {
        await examRef.collection('questions').add({
          "question": question["question"],
          "options": question["options"],
          "answer": question["answer"],
          "ansExplanation": question["ansExplanation"],
          "difficulty": question["difficulty"],
          "imageUrl": question["imageUrl"],
          "marks": question["marks"],
          "tags": question["tags"],
        });
        log("Question added to exam ${widget.examId}");
      }

      // Clear fields after saving
      setState(() {
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to QuizPreviewPage with the examId and teacherDocId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPreviewPage(
                        examId: widget.examId,
                        teacherDocId: widget.teacherDocId,
                      ),
                    ),
                  );
                },
                child: const Text('Preview Quiz'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
