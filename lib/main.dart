import 'dart:developer';
import 'package:examiner_bigaze/Screens/authgate.dart';
import 'package:examiner_bigaze/Screens/homescreen.dart';
import 'package:examiner_bigaze/provider/authprovider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For state management
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // This will be called when the app is in the foreground
    log('Foreground message received: ${message.notification?.title}');
    // You can show a dialog or notification in the app here
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Dynamically show the login screen or home screen based on the login state
          return authProvider.isLoggedIn
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
