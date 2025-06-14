import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/search_bar.dart';
import '../widgets/subject_section.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectsProvider>();
    final isLoading = subjects.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => subjects.fetchSubjects(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Header(),
                        const SizedBox(height: 24),
                        const SearchBarWidget(),
                        const SizedBox(height: 24),
                        const Text(
                          'Explorez les matières',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SubjectSection(type: 'main'),
                        const SizedBox(height: 24),
                        const SubjectSection(type: 'complementary'),
                        const SizedBox(
                            height: 80), // Space for bottom navigation
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
