import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:examiner_bigaze/quizcreatepage.dart';
import 'package:examiner_bigaze/quizmanager.dart';
import 'package:examiner_bigaze/sendnotificationpage.dart';
import 'package:examiner_bigaze/testentry.dart';
import 'package:examiner_bigaze/testlist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/icon/bigaze.png"),
        title: const Text(
          "E X A M   M A N A G E R",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
      body: Stack(
        children: [
          // Background GIF
          Positioned.fill(
            child: Image.asset(
              './assets/icon/GWqs.gif', // Path to your GIF
              fit: BoxFit.cover, // Make sure the GIF covers the screen
            ),
          ),
          // Foreground Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGlassTile(
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
                  _buildGlassTile(
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
                  _buildGlassTile(
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
                  _buildGlassTile(
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
        ],
      ),
    );
  }

  Widget _buildGlassTile(
      BuildContext context, String label, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), // Light transparency
        borderRadius: BorderRadius.circular(20), // Round corners
        border: Border.all(
          width: 1,
          color: Colors.white.withOpacity(0.3), // Light border
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color.fromARGB(
            60, 97, 97, 97), // Transparent material background
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // This container creates the frosted glass effect
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.1), // Transparent white overlay
                          backgroundBlendMode: BlendMode.darken,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // child: BackdropFilter(
                        //   filter: ImageFilter.blur(
                        //       sigmaX: 10.0, sigmaY: 10.0), // Apply blur effect
                        //   child: Container(
                        //       color: Colors
                        //           .transparent), // Just a transparent container for blur
                        // ),
                      ),
                    ),
                    // Text on top of the glass effect
                    // Center(
                    //   child: Text(
                    //     label,
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 2,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
