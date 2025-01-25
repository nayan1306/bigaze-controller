import 'package:firebase_auth/firebase_auth.dart';
import 'package:examiner_bigaze/Screens/student_controller/custom_qr_code.dart';
import 'package:flutter/material.dart';

class QrCodeGenerator extends StatelessWidget {
  const QrCodeGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    // Create a JSON object with the required user details
    final Map<String, dynamic> userData = {
      'id': user?.uid ?? 'No User ID',
      'name': user?.displayName ?? 'No Name',
      'profilePicUrl': user?.photoURL ?? 'No Profile Picture',
      'email': user?.email ?? 'No Email',
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CustomQrCode(
            data: userData.toString(), // Pass the JSON as a string
          ),
        ),
      ),
    );
  }
}
