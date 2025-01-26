import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_to_image/qr_code_to_image.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({super.key});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQrCodeScreen();
    });
  }

  void _showQrCodeScreen() {
    // Get the current user from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    // Create a JSON object with the required user details
    final Map<String, dynamic> userData = {
      'id': user?.uid ?? 'No User ID',
      'name': user?.displayName ?? 'No Name',
      'profilePicUrl': user?.photoURL ?? 'No Profile Picture',
      'email': user?.email ?? 'No Email',
    };

    // Automatically show the QR code screen
    QrCodeToImage.showQrCodeScreen(
      context,
      textQrCode: userData.toString(), // QR data
      textButton: "Share",
      colorWidgetTest: Colors.blue, // Customize button color
    ).then((_) {
      // Close the widget once the QR code screen is dismissed
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Minimal widget as no UI is needed
  }
}
