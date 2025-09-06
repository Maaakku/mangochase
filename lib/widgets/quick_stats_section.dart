// quick_stats_section.dart

import 'package:flutter/material.dart';

class QuickStatsSection extends StatelessWidget {
  final VoidCallback onSeeMore;

  const QuickStatsSection({super.key, required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    // Data for each summary box, including details
    final List<Map<String, dynamic>> boxes = [
      {
        'icon': Icons.nature,
        'title': 'Mango Tree',
        'desc': 'Total mango trees: 12\nEach cluster has 10 trees.',
        'details': 'You have 12 mango trees in total. Each cluster contains 10 trees. All trees are currently healthy and producing fruit.',
      },
      {
        'icon': Icons.shopping_basket,
        'title': 'Harvest',
        'desc': 'Upcoming harvest: 3\nLast: Aug 2025.',
        'details': 'Upcoming harvest dates:\n- Sep 10, 2025\n- Sep 18, 2025\n- Sep 25, 2025\n- Oct 2, 2025\n- Oct 9, 2025',
      },
      {
        'icon': Icons.event_note,
        'title': 'Next Task',
        'desc': 'Pest Control\n(Sep 20)',
        'details': 'Next task: Pest control scheduled for Sep 20. Other tasks for this month include irrigation and fertilization.',
      },
      {
        'icon': Icons.health_and_safety,
        'title': 'Tree Health',
        'desc': 'Healthy: 95%\nMonitor 1 tree.',
        'details': 'Tree #7 needs attention: signs of leaf spot detected. All other trees are healthy.',
      },
      
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Quick Stats & See More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Summary Overview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
          const Divider(height: 16, thickness: 1),
          SizedBox(height: 16),
          // 2x2 Staggered Grid of Summary Boxes
          Row(
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: [
                    _summaryBox(context, boxes[0]),
                    const SizedBox(height: 16),
                    _summaryBox(context, boxes[2]),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right column with offset
              Expanded(
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 16),
                      child: _summaryBox(context, boxes[1]),
                    ),
                    const SizedBox(height: 16),
                    Transform.translate(
                      offset: const Offset(0, 16),
                      child: _summaryBox(context, boxes[3]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

        ],
      ),
    );
  }

  // Individual summary box widget
  Widget _summaryBox(BuildContext context, Map<String, dynamic> data) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => _detailsSheet(context, data),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(data['icon'], size: 40, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['desc'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal bottom sheet for details, with See More button
  Widget _detailsSheet(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data['icon'], size: 32, color: Colors.orange),
              const SizedBox(width: 12),
              Text(
                data['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data['details'],
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('See More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Add your routing/navigation logic here
                // Example:
                // Navigator.push(context, MaterialPageRoute(builder: (_) => DetailedPage()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
