//quick_stats_section.dart
import 'package:flutter/material.dart';

class QuickStatsSection extends StatelessWidget {
  final VoidCallback onSeeMore;

  const QuickStatsSection({super.key, required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Quick Stats & See More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Stats',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: onSeeMore,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('See More'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          // Bottom Column: Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              StatRow(label: 'Total Mango Trees', value: '12'),
              SizedBox(height: 8),
              StatRow(label: 'Upcoming Harvest', value: '3'),
              SizedBox(height: 8),
              StatRow(label: 'Next Task', value: 'Pest Control (Sep 20)'),
            ],
          ),
        ],
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}