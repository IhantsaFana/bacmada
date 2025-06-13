import 'package:flutter/material.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Toutes les matières',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                SubjectSection(type: 'main'),
                SizedBox(height: 16),
                SubjectSection(type: 'complementary'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
