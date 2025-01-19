import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizManager extends StatefulWidget {
  const QuizManager({super.key});

  @override
  State<QuizManager> createState() => _QuizManagerState();
}

class _QuizManagerState extends State<QuizManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sample data
  final List<Map<String, dynamic>> quizzes = [
    {
      "title": "General Knowledge",
      "description": "Test your knowledge on various topics",
      "maxMarks": 50,
      "createdBy": "Prof. ABC",
      "timeLimit": 30,
      "isPublished": true,
      "visibility": "public",
      "questions": [
        {
          "title": "What was Stephen Hawking's minor project?",
          "options": [
            "Minor Blackhole",
            "Michal Jackson Moon",
            "White Hole Island",
            "13 Blackhole"
          ],
          "answer": "Delhi",
          "marks": 5
        },
        {
          "title": "Who wrote 'Romeo and Juliet'?",
          "options": [
            "Charles Dickens",
            "William Shakespeare",
            "Leo Tolstoy",
            "J.K. Rowling"
          ],
          "answer": "William Shakespeare",
          "marks": 5
        },
        {
          "title": "What is the largest planet in our Solar System?",
          "options": ["Earth", "Mars", "Jupiter", "Saturn"],
          "answer": "Jupiter",
          "marks": 5
        },
        {
          "title": "What is the chemical symbol for gold?",
          "options": ["Au", "Ag", "Fe", "O"],
          "answer": "Au",
          "marks": 5
        },
        {
          "title": "Who painted the Mona Lisa?",
          "options": [
            "Vincent Van Gogh",
            "Pablo Picasso",
            "Leonardo da Vinci",
            "Michelangelo"
          ],
          "answer": "Leonardo da Vinci",
          "marks": 5
        },
        {
          "title": "What is the hardest natural substance on Earth?",
          "options": ["Gold", "Iron", "Diamond", "Quartz"],
          "answer": "Diamond",
          "marks": 5
        },
        {
          "title": "What is the capital of France?",
          "options": ["Lyon", "Marseille", "Paris", "Nice"],
          "answer": "Paris",
          "marks": 5
        },
        {
          "title": "How many continents are there?",
          "options": ["5", "6", "7", "8"],
          "answer": "7",
          "marks": 5
        },
        {
          "title": "What is the largest ocean on Earth?",
          "options": [
            "Atlantic Ocean",
            "Indian Ocean",
            "Arctic Ocean",
            "Pacific Ocean"
          ],
          "answer": "Pacific Ocean",
          "marks": 5
        },
        {
          "title": "Who is known as the father of computers?",
          "options": [
            "Charles Babbage",
            "Alan Turing",
            "Bill Gates",
            "Steve Jobs"
          ],
          "answer": "Charles Babbage",
          "marks": 5
        }
      ]
    },
    {
      "title": "Science",
      "description": "Test your understanding of scientific concepts",
      "maxMarks": 60,
      "createdBy": "Prof. XYZ",
      "timeLimit": 45,
      "isPublished": true,
      "visibility": "public",
      "questions": [
        {
          "title": "What is the chemical symbol for water?",
          "options": ["H2O", "CO2", "NaCl", "O2"],
          "answer": "H2O",
          "marks": 6
        },
        {
          "title": "What is the boiling point of water in Celsius?",
          "options": ["0", "100", "50", "200"],
          "answer": "100",
          "marks": 6
        },
        {
          "title": "What is the closest star to Earth?",
          "options": ["Proxima Centauri", "Sun", "Alpha Centauri", "Sirius"],
          "answer": "Sun",
          "marks": 6
        },
        {
          "title": "What is the powerhouse of the cell?",
          "options": [
            "Ribosome",
            "Nucleus",
            "Mitochondria",
            "Endoplasmic reticulum"
          ],
          "answer": "Mitochondria",
          "marks": 6
        },
        {
          "title": "What is the chemical symbol for oxygen?",
          "options": ["O", "O2", "CO2", "H2O"],
          "answer": "O2",
          "marks": 6
        },
        {
          "title": "What is the freezing point of water in Fahrenheit?",
          "options": ["32", "0", "100", "212"],
          "answer": "32",
          "marks": 6
        },
        {
          "title": "What is the force that opposes motion?",
          "options": ["Gravity", "Friction", "Momentum", "Acceleration"],
          "answer": "Friction",
          "marks": 6
        },
        {
          "title": "What is the unit of electric current?",
          "options": ["Ohm", "Ampere", "Watt", "Volt"],
          "answer": "Ampere",
          "marks": 6
        },
        {
          "title": "What is the study of earthquakes called?",
          "options": ["Seismology", "Meteorology", "Ecology", "Geology"],
          "answer": "Seismology",
          "marks": 6
        },
        {
          "title": "Which gas is most abundant in Earth's atmosphere?",
          "options": ["Nitrogen", "Oxygen", "Carbon dioxide", "Argon"],
          "answer": "Nitrogen",
          "marks": 6
        }
      ]
    },
    // Add remaining quizzes in a similar format
  ];

  Future<void> addQuizzes() async {
    for (var quiz in quizzes) {
      try {
        // Add quiz to Firestore
        DocumentReference quizRef = await _firestore.collection('Quiz').add({
          "title": quiz["title"],
          "description": quiz["description"],
          "maxMarks": quiz["maxMarks"],
          "createdBy": quiz["createdBy"],
          "timeLimit": quiz["timeLimit"],
          "isPublished": quiz["isPublished"],
          "visibility": quiz["visibility"],
          "createdAt": FieldValue.serverTimestamp(),
        });
        log("Quiz added with ID: ${quizRef.id}");

        // Add questions to the 'Questions' subcollection
        for (var question in quiz["questions"]) {
          await _firestore
              .collection('Quiz/${quizRef.id}/Questions')
              .add(question);
          log("Question added to quiz ${quizRef.id}");
        }
      } catch (e) {
        log("Error adding quiz: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: addQuizzes,
          child: const Text("Add Quizzes to Firestore"),
        ),
      ),
    );
  }
}
