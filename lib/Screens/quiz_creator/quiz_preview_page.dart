import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InteractiveQuizPage extends StatefulWidget {
  final String examId;
  final String teacherDocId;

  const InteractiveQuizPage({
    super.key,
    required this.examId,
    required this.teacherDocId,
  });

  @override
  _InteractiveQuizPageState createState() => _InteractiveQuizPageState();
}

class _InteractiveQuizPageState extends State<InteractiveQuizPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> questions = [];
  // Map storing student's answer: question index -> selected option (int)
  Map<int, int> studentAnswers = {};
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  /// Fetch questions from Firestore ordered by the 'createdAt' field.
  Future<void> _fetchQuestions() async {
    try {
      DocumentReference examRef = _firestore
          .collection('teacher')
          .doc(widget.teacherDocId)
          .collection('exams')
          .doc(widget.examId);

      QuerySnapshot querySnapshot = await examRef
          .collection('questions')
          .orderBy('createdAt', descending: false)
          .get();

      setState(() {
        questions = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            "number": data['number']?.toString() ?? '',
            "question": data['question'] ?? '',
            "options": data['options'] ?? {},
            "answer": data['answer'] ?? 0,
            "ansExplanation": data['ansExplanation'] ?? '',
            "difficulty": data['difficulty'] ?? '',
            "imageUrl": data['imageUrl'] ?? '',
            "marks": data['marks'] ?? 0,
            "tags": data['tags'] is List
                ? List<String>.from(data['tags'])
                : <String>[],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching questions: $e");
    }
  }

  /// Calculates the student's score and displays the result.
  void _submitQuiz() {
    // Optionally check for unanswered questions.
    if (studentAnswers.length < questions.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Quiz"),
          content: const Text("Some questions are unanswered. Submit anyway?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _calculateScore();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );
    } else {
      _calculateScore();
    }
  }

  void _calculateScore() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      int correctAnswer = questions[i]["answer"];
      if (studentAnswers[i] == correctAnswer) {
        score++;
      }
    }
    setState(() {
      isSubmitted = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Results"),
        content: Text("Your score is $score out of ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Builds a widget for a single option.
  Widget _buildOption(int questionIndex, String optionKey, String optionText) {
    // Convert optionKey to integer.
    int optionValue = int.tryParse(optionKey) ?? 0;
    bool isSelected = studentAnswers[questionIndex] == optionValue;
    bool showCorrect = isSubmitted;
    bool isCorrect = (optionValue == questions[questionIndex]["answer"]);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: showCorrect
              ? (isCorrect ? Colors.green : Colors.red)
              : Colors.grey.shade400,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        color: showCorrect
            ? (isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1))
            : Colors.transparent,
      ),
      child: RadioListTile<int>(
        value: optionValue,
        groupValue: studentAnswers[questionIndex],
        onChanged: isSubmitted
            ? null
            : (value) {
                setState(() {
                  studentAnswers[questionIndex] = value!;
                });
              },
        title: Text(optionText, style: const TextStyle(fontSize: 16)),
        activeColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Quiz"),
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final optionsMap = question["options"] as Map;
                List<String> sortedKeys = optionsMap.keys
                    .map((e) => e.toString())
                    .toList()
                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display question number and text.
                        Text(
                          question["number"].toString().isNotEmpty
                              ? 'Q${question["number"]}. ${question["question"]}'
                              : question["question"],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Display interactive options.
                        ...sortedKeys.map((key) {
                          return _buildOption(
                              index, key, optionsMap[key] ?? '');
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color.fromARGB(0, 26, 24, 24),
        child: ElevatedButton(
          onPressed: isSubmitted ? null : _submitQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 109, 154, 58),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Submit Quiz",
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ),
      ),
    );
  }
}
