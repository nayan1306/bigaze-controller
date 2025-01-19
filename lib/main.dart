import 'dart:developer';
import 'package:examiner_bigaze/quizcreatepage.dart';
import 'package:examiner_bigaze/quizmanager.dart';
import 'package:examiner_bigaze/sendnotificationpage.dart';
import 'package:examiner_bigaze/testentry.dart';
import 'package:examiner_bigaze/testlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // This will be called when the app is in the foreground
    log('Foreground message received: ${message.notification?.title}');
    // You can show a dialog or notification in the app here
  });

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  log('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Manager',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 0, 0, 0), // Dark theme background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/icon/bigaze.png"),
        title: const Text("E X A M   M A N A G E R",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizManager(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradientTile(
                context,
                'Schedule Exam',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestEntryPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildGradientTile(
                context,
                'View Exams',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestListPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildGradientTile(
                context,
                'Create Quiz',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateQuizPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildGradientTile(
                context,
                'Send Notification',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SendNotificationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientTile(
      BuildContext context, String label, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color:
            const Color.fromARGB(255, 0, 0, 0), // Tile filled with black color
        borderRadius: BorderRadius.circular(20), // Slight round corners
        border: Border.all(
          width: 2,
          color:
              Colors.transparent, // No internal color, just the gradient border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5), // Purple shadow for effect
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4), // Shadow position
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 175, 140, 231), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white, // White text on black background
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
