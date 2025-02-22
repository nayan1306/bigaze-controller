import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examiner_bigaze/Screens/proctor_parameters.dart';
import 'package:examiner_bigaze/Screens/quiz_creator/question_card.dart';
import 'package:examiner_bigaze/Screens/quiz_creator/quiz_preview_page.dart';
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

  // Local unsaved questions added in the current session.
  List<Map<String, dynamic>> localQuestions = [];

  /// Returns a stream of saved questions from Firestore,
  /// ordered by 'createdAt' (oldest first).
  Stream<QuerySnapshot> getSavedQuestionsStream() {
    DocumentReference examRef = _firestore
        .collection('teacher')
        .doc(widget.teacherDocId)
        .collection('exams')
        .doc(widget.examId);
    return examRef
        .collection('questions')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Adds a new unsaved question locally.
  void addLocalQuestion() {
    setState(() {
      localQuestions.add({
        "number": localQuestions.length + 1, // auto numbering based on count
        "question": "",
        "options": {"1": "", "2": "", "3": "", "4": ""},
        "answer": 0,
        "ansExplanation": "",
        "difficulty": "medium",
        "imageUrl": "",
        "marks": 0,
        "tags": [],
      });
    });
  }

  /// Updates a field of a local (unsaved) question.
  void updateLocalQuestion(int index, String field, dynamic value) {
    setState(() {
      localQuestions[index][field] = value;
    });
  }

  /// Updates an option for a local question.
  void updateLocalOption(int questionIndex, String optionKey, String value) {
    setState(() {
      localQuestions[questionIndex]["options"][optionKey] = value;
    });
  }

  /// Saves all unsaved (local) questions to Firestore.
  Future<void> saveLocalQuestions() async {
    try {
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId);

      // Create exam document if it doesn't exist.
      if (!(await examRef.get()).exists) {
        await examRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      for (var question in localQuestions) {
        await examRef.collection('questions').add({
          "number": question["number"],
          "question": question["question"],
          "options": question["options"],
          "answer": question["answer"],
          "ansExplanation": question["ansExplanation"],
          "difficulty": question["difficulty"],
          "imageUrl": question["imageUrl"],
          "marks": question["marks"],
          "tags": question["tags"],
          "createdAt": FieldValue.serverTimestamp(),
        });
        log("Question added to exam ${widget.examId}");
      }

      setState(() {
        localQuestions.clear();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Use a StreamBuilder to listen to saved questions.
        child: StreamBuilder<QuerySnapshot>(
          stream: getSavedQuestionsStream(),
          builder: (context, snapshot) {
            List<Map<String, dynamic>> savedQuestions = [];
            if (snapshot.hasData) {
              savedQuestions = snapshot.data!.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            }
            // Combine saved and unsaved questions.
            List<Map<String, dynamic>> allQuestions = [
              ...savedQuestions,
              ...localQuestions
            ];
            // Sort by question number.
            allQuestions.sort(
                (a, b) => (a["number"] as int).compareTo(b["number"] as int));

            if (allQuestions.isEmpty) {
              return Center(
                child: Text(
                  'No questions added yet.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            return ListView.separated(
              itemCount: allQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return QuestionCard(
                  question: allQuestions[index],
                  onQuestionChanged: (field, value) {
                    // Allow editing only for unsaved (local) questions.
                    int localIndex = localQuestions.indexWhere(
                        (q) => q["number"] == allQuestions[index]["number"]);
                    if (localIndex != -1) {
                      updateLocalQuestion(localIndex, field, value);
                    } else {
                      // Optionally, implement update functionality for saved questions.
                    }
                  },
                  onOptionChanged: (optionKey, value) {
                    int localIndex = localQuestions.indexWhere(
                        (q) => q["number"] == allQuestions[index]["number"]);
                    if (localIndex != -1) {
                      updateLocalOption(localIndex, optionKey, value);
                    } else {
                      // Optionally, implement update functionality for saved questions.
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(100, 28, 28, 28),
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First row: Add and Save buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuizActionButton(
                    label: 'Add Question',
                    icon: Icons.add,
                    backgroundColor: const Color.fromARGB(255, 154, 178, 104),
                    onPressed: addLocalQuestion,
                  ),
                  const SizedBox(width: 10),
                  QuizActionButton(
                    label: 'Save',
                    icon: Icons.save,
                    backgroundColor: const Color.fromARGB(255, 129, 198, 255),
                    onPressed: saveLocalQuestions,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Second row: Preview and Proctor buttons.
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
                          builder: (context) => InteractiveQuizPage(
                            examId: widget.examId,
                            teacherDocId: widget.teacherDocId,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
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
        fixedSize: const Size(155, 40),
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
