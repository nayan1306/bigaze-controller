import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizPreviewPage extends StatefulWidget {
  final String examId;
  final String teacherDocId;

  const QuizPreviewPage({
    super.key,
    required this.examId,
    required this.teacherDocId,
  });

  @override
  _QuizPreviewPageState createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends State<QuizPreviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Fetch the questions from Firestore
  Future<void> _fetchQuestions() async {
    try {
      // Reference to the specific exam and teacher
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId);

      // Fetch the questions sub-collection
      QuerySnapshot querySnapshot = await examRef.collection('questions').get();

      // Populate the questions list
      setState(() {
        questions = querySnapshot.docs.map((doc) {
          return {
            "question": doc['question'],
            "options": doc['options'],
            "answer": doc['answer'],
            "ansExplanation": doc['ansExplanation'],
            "difficulty": doc['difficulty'],
            "imageUrl": doc['imageUrl'],
            "marks": doc['marks'],
            "tags": List<String>.from(doc['tags']),
          };
        }).toList();
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: questions.isEmpty
            ? const Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching
            : ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Question: ${question["question"]}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          for (var option in question["options"].entries)
                            Text('Option ${option.key}: ${option.value}'),
                          const SizedBox(height: 8),
                          Text('Correct Answer: Option ${question["answer"]}'),
                          const SizedBox(height: 8),
                          Text(
                              'Answer Explanation: ${question["ansExplanation"]}'),
                          const SizedBox(height: 8),
                          Text('Difficulty: ${question["difficulty"]}'),
                          const SizedBox(height: 8),
                          Text('Marks: ${question["marks"]}'),
                          const SizedBox(height: 8),
                          Text('Tags: ${question["tags"].join(', ')}'),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
