import 'package:flutter/material.dart';
import 'widgets/bacmada_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/subject_section.dart';

class MatierePage extends StatelessWidget {
  const MatierePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                BacMadaHeader(),
                SizedBox(height: 16),
                SearchBarWidget(),
                SizedBox(height: 16),
                SubjectSection(),
                SizedBox(height: 16),
                ComplementarySubjectsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
