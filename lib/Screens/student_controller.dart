import 'package:examiner_bigaze/Screens/student_controller/add_mail.dart';
import 'package:flutter/material.dart';

class StudentController extends StatefulWidget {
  const StudentController({super.key});

  @override
  State<StudentController> createState() => _StudentControllerState();
}

class _StudentControllerState extends State<StudentController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    // Action for QR code button
                  },
                  icon: const Icon(Icons.qr_code),
                ),
                IconButton(
                  onPressed: () {
                    // Action for group add button
                  },
                  icon: const Icon(Icons.group_add),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMail()),
                    );
                  },
                  icon: const Icon(Icons.mail),
                ),
                IconButton(
                  onPressed: () {
                    // Action for person add button
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with your dynamic item count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Item $index'),
                      tileColor: const Color.fromARGB(255, 42, 42, 42),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
