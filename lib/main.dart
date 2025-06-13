// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'auth_page.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/subjects_provider.dart';
import 'screens/home_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BacMadaApp());
}

class BacMadaApp extends StatelessWidget {
  const BacMadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
        ChangeNotifierProvider(create: (_) => SubjectsProvider()),
      ],
      child: MaterialApp(
        title: 'BacMada',
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

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
