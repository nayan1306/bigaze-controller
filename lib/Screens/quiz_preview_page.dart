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
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId);

      QuerySnapshot querySnapshot = await examRef.collection('questions').get();

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
            "docId": doc.id, // Store the document ID for easy access
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  // Function to open a dialog to edit a question
  void _editQuestion(Map<String, dynamic> question) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController questionController =
        TextEditingController(text: question['question']);
    final TextEditingController ansExplanationController =
        TextEditingController(text: question['ansExplanation']);
    final TextEditingController difficultyController =
        TextEditingController(text: question['difficulty']);
    final TextEditingController imageUrlController =
        TextEditingController(text: question['imageUrl']);
    final TextEditingController marksController =
        TextEditingController(text: question['marks'].toString());
    final TextEditingController tagsController =
        TextEditingController(text: question['tags'].join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Question'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: ansExplanationController,
                    decoration: const InputDecoration(
                      labelText: 'Answer Explanation',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: difficultyController,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty (easy, medium, hard)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: marksController,
                    decoration: const InputDecoration(
                      labelText: 'Marks',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter marks';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  // Update the question in Firestore
                  try {
                    DocumentReference questionRef = _firestore
                        .collection('teacher')
                        .doc(widget.teacherDocId)
                        .collection('exams')
                        .doc(widget.examId)
                        .collection('questions')
                        .doc(question['docId']);

                    await questionRef.update({
                      'question': questionController.text,
                      'ansExplanation': ansExplanationController.text,
                      'difficulty': difficultyController.text,
                      'imageUrl': imageUrlController.text,
                      'marks': int.parse(marksController.text),
                      'tags': tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .toList(),
                    });

                    // Refresh the question list
                    _fetchQuestions();

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Question updated successfully!')),
                    );
                  } catch (e) {
                    print('Error updating question: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to update question')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                  return GestureDetector(
                    onLongPress: () {
                      // Open the edit question dialog
                      _editQuestion(question);
                    },
                    child: Card(
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
                            Text(
                                'Correct Answer: Option ${question["answer"]}'),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}
