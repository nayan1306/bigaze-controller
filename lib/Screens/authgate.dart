import 'package:examiner_bigaze/provider/authprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: () async {
            await authProvider.login();
          },
          height: 50,
          minWidth: 100,
          color: Colors.red,
          child: const Text(
            'Google Sign-In',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
