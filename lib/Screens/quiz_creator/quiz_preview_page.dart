import 'dart:async';
import 'dart:developer';
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
  int score = 0;

  // Timer fields: total quiz duration in seconds (e.g., 30 minutes = 1800 sec)
  Timer? _timer;
  int timeRemaining = 1800;

  // Page controller for question navigation.
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining <= 0) {
        timer.cancel();
        _submitQuiz(); // Auto-submit when time runs out.
      } else {
        setState(() {
          timeRemaining--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
            "tags": data['tags'] is List ? List<String>.from(data['tags']) : [],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching questions: $e");
    }
  }

  /// Submits the quiz—checks unanswered questions and then calculates score.
  void _submitQuiz() {
    if (isSubmitted) return; // Prevent double submission

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
    int calculatedScore = 0;
    for (int i = 0; i < questions.length; i++) {
      int correctAnswer = questions[i]["answer"];
      if (studentAnswers[i] == correctAnswer) {
        calculatedScore++;
      }
    }
    setState(() {
      isSubmitted = true;
      score = calculatedScore;
    });
    _timer?.cancel();

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
    int optionValue = int.tryParse(optionKey) ?? 0;
    bool isSelected = studentAnswers[questionIndex] == optionValue;
    bool showCorrect = isSubmitted;
    bool isCorrect = optionValue == questions[questionIndex]["answer"];

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

  /// Builds a horizontal list of question navigator dots.
  Widget _buildQuestionNavigator() {
    return Wrap(
      spacing: 8,
      children: List.generate(questions.length, (index) {
        bool isCurrent = currentPage == index;
        Color dotColor;
        if (!isSubmitted) {
          dotColor =
              studentAnswers.containsKey(index) ? Colors.green : Colors.grey;
        } else {
          if (!studentAnswers.containsKey(index)) {
            dotColor = Colors.grey; // unanswered
          } else {
            dotColor = (studentAnswers[index] == questions[index]["answer"])
                ? Colors.green
                : Colors.red;
          }
        }
        return GestureDetector(
          onTap: () {
            _pageController.jumpToPage(index);
            setState(() {
              currentPage = index;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? Colors.blue : dotColor,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Builds the top bar with timer, progress, and result summary (if submitted).
  Widget _buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer and progress.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Time Remaining: ${_formatTime(timeRemaining)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Q ${currentPage + 1} / ${questions.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildQuestionNavigator(),
        if (isSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Score: $score / ${questions.length}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = questions[index];
    final optionsMap = question["options"] as Map;
    List<String> sortedKeys = optionsMap.keys.map((e) => e.toString()).toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Display each option.
              ...sortedKeys.map((key) {
                return _buildOption(index, key, optionsMap[key] ?? '');
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QUIZ Preview"),
      ),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildTopBar(),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: questions.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(index);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color.fromARGB(0, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            ElevatedButton(
              onPressed: currentPage > 0 && !isSubmitted
                  ? () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Previous"),
            ),
            // Submit Quiz button
            ElevatedButton(
              onPressed: !isSubmitted ? _submitQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 109, 154, 58),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Submit Quiz", style: TextStyle(fontSize: 18)),
            ),
            // Next button
            ElevatedButton(
              onPressed: currentPage < questions.length - 1 && !isSubmitted
                  ? () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
