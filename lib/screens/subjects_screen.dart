import 'package:flutter/material.dart';
import '../widgets/bacmada_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/subject_section.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const BacMadaHeader(),
                const SizedBox(height: 16),
                const SearchBarWidget(),
                const SizedBox(height: 24),
                const SubjectSection(type: 'main'),
                const SizedBox(height: 24),
                const SubjectSection(type: 'complementary'),
                const SizedBox(
                    height: 80), // Espace pour la bottom navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
