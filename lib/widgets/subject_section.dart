import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subjects_provider.dart';
import 'subject_card.dart';

class SubjectSection extends StatelessWidget {
  final String type;

  const SubjectSection({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectsProvider>().getSubjectsByType(type);
    final title =
        type == 'main' ? 'Matières principales' : 'Matières complémentaires';
    final color = type == 'main' ? Colors.indigo : Colors.green;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade400, color.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: -8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  // TODO: Naviguer vers la liste complète des matières
                },
                child: const Row(
                  children: [
                    Text(
                      'Voir tout',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (subjects.isEmpty)
            const Center(
              child: Text(
                'Aucune matière disponible',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == subjects.length - 1 ? 0 : 8),
                  child: SubjectCard(
                    subject: subject,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
