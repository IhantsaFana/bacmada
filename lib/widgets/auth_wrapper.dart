import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../screens/home_navigation.dart';
import '../auth_page.dart';
import '../providers/subjects_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user != null) {
      // Charger les matières quand l'utilisateur est connecté
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SubjectsProvider>().fetchSubjects();
      });
      return const HomeNavigation();
    }
    return const AuthPage();
  }
}
