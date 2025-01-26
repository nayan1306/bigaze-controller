import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class AddMail extends StatefulWidget {
  const AddMail({super.key});

  @override
  State<AddMail> createState() => _AddMailState();
}

class _AddMailState extends State<AddMail> {
  final TextEditingController _emailController = TextEditingController();

  // Function to add email
  void _addEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email!')),
      );
      return;
    }

    // Process the email (e.g., store it in Firestore or perform other actions)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email $email added successfully!')),
    );

    // You can add your custom logic here (e.g., saving to Firestore)
    _emailController.clear(); // Clear input field after successful addition
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Add Email'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Email input field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Enter email address',
                border: OutlineInputBorder(),
                hintText: 'example@example.com',
              ),
            ),
            const SizedBox(height: 20),
            // Add button
            Center(
              child: ElevatedButton(
                onPressed: _addEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(139, 193, 193, 193),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text(
                  'Add Email',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
