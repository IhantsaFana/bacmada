import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SubjectProgressChart extends StatelessWidget {
  final String subject;
  final double progress;
  final Color color;
  final int quizCount;
  final int chaptersCount;

  const SubjectProgressChart({
    super.key,
    required this.subject,
    required this.progress,
    required this.color,
    required this.quizCount,
    required this.chaptersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: progress,
                            color: color,
                            radius: 10,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - progress,
                            color: color.withOpacity(0.1),
                            radius: 10,
                            showTitle: false,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 35,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${progress.round()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStat(
                      Icons.quiz,
                      '$quizCount quiz terminés',
                      color,
                    ),
                    const SizedBox(height: 8),
                    _buildStat(
                      Icons.menu_book,
                      '$chaptersCount chapitres',
                      color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
