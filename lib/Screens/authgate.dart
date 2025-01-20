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
          height: 40,
          minWidth: 40,
          color: const Color.fromARGB(105, 68, 68, 68),
          child: Image.asset(
            './assets/icon/google.png',
            width: 40,
            height: 60,
          ),
        ),
      ),
    );
  }
}
