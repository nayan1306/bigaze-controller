import 'package:examiner_bigaze/Screens/profilescreen.dart';
import 'package:examiner_bigaze/Screens/questiondesigner.dart';
import 'package:examiner_bigaze/widgets/glasstile.dart';
import 'package:flutter/material.dart';
import 'package:examiner_bigaze/quizmanager.dart';
import 'package:examiner_bigaze/sendnotificationpage.dart';
import 'package:examiner_bigaze/schedule_exam_page.dart';
import 'package:examiner_bigaze/testlist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/icon/splash_image.png"),
        title: const Text(
          "BiG∆ZE MΞNTOR",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      // extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background GIF
          Positioned.fill(
            child: Image.asset(
              './assets/bg.gif', // Path to your GIF
              fit: BoxFit.cover, // Make sure the GIF covers the screen
              // colorBlendMode: BlendMode.darken,
            ),
          ),
          // Foreground Content
          SingleChildScrollView(
            // Wrap the content in a scrollable view
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassTile(
                      context,
                      'Exam Controller',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GlassTile(
                      context,
                      'Schedule Exam',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScheduleExamPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GlassTile(
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
                    GlassTile(
                      context,
                      'Create Quiz',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamListPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GlassTile(
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
                    // temp
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
