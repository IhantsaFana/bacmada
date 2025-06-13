import 'package:flutter/material.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 32),
                  AuthForm(
                    isLogin: isLogin,
                    onToggle: toggleForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
