import 'package:flutter/material.dart';

// Sample data for Quick Stats
final List<Map<String, dynamic>> quickStatsData = [
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