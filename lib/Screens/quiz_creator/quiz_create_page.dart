import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/proctor_parameters.dart';
import 'package:examiner_bigaze/Screens/quiz_creator/question_card.dart';
import 'package:examiner_bigaze/Screens/quiz_preview_page.dart';
import 'package:flutter/material.dart';

class QuizCreatePage extends StatefulWidget {
  final String examId; // Exam ID passed from ExamListPage
  final String teacherDocId; // Teacher document ID passed from ExamListPage

  const QuizCreatePage({
    super.key,
    required this.examId,
    required this.teacherDocId,
  });

  @override
  _QuizCreatePageState createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends State<QuizCreatePage> {
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

  // Update a specific option for a question
  void updateOption(int questionIndex, String optionKey, String value) {
    setState(() {
      questions[questionIndex]["options"][optionKey] = value;
    });
  }

  // Save quiz to Firestore
  Future<void> saveQuiz() async {
    try {
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId);

      // Create exam document if it doesn't exist
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
      // The body contains a scrollable list of question cards.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: questions.isEmpty
            ? Center(
                child: Text(
                  'No questions added yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return QuestionCard(
                    question: questions[index],
                    onQuestionChanged: (field, value) =>
                        updateQuestion(index, field, value),
                    onOptionChanged: (optionKey, value) =>
                        updateOption(index, optionKey, value),
                  );
                },
              ),
      ),
      // Fixed action buttons at the bottom of the screen.
      bottomNavigationBar: Container(
        color: const Color.fromARGB(100, 28, 28, 28),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuizActionButton(
                    label: 'Add Question',
                    icon: Icons.add,
                    backgroundColor: const Color.fromARGB(255, 154, 178, 104),
                    onPressed: addQuestion,
                  ),
                  const SizedBox(
                    height: 10,
                    width: 10,
                  ),
                  QuizActionButton(
                    label: 'Save ',
                    icon: Icons.save,
                    backgroundColor: const Color.fromARGB(255, 129, 198, 255),
                    onPressed: saveQuiz,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuizActionButton(
                    label: 'Preview Quiz',
                    icon: Icons.preview,
                    backgroundColor: const Color.fromARGB(255, 253, 198, 110),
                    onPressed: () {
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
                  ),
                  const SizedBox(
                    height: 10,
                    width: 10,
                  ),
                  QuizActionButton(
                    label: 'Proctor',
                    icon: Icons.settings,
                    backgroundColor: const Color.fromARGB(255, 239, 150, 255),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProctorParametersPage(
                            examId: widget.examId,
                            teacherDocId: widget.teacherDocId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable action button widget with a sleek and minimal design.
class QuizActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const QuizActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(155, 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: backgroundColor,
        elevation: 4,
        shadowColor: Colors.white.withOpacity(0.5),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}
