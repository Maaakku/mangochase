//home_dashboard.dart
import 'package:flutter/material.dart';
import '../widgets/mango_track_appbar.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/recent_inspected_trees_section.dart';

// Sample data for recent inspected trees
final List<RecentInspectedTree> recentTrees = [
  RecentInspectedTree(treeNumber: 1, stage: 'Growing', predictedHarvest: '15 Mangoes', harvestDate: 'Oct 10, 2025'),
  RecentInspectedTree(treeNumber: 2, stage: 'Flowering', predictedHarvest: '20 Mangoes', harvestDate: 'Oct 15, 2025'),
  RecentInspectedTree(treeNumber: 3, stage: 'Ripening', predictedHarvest: '12 Mangoes', harvestDate: 'Oct 20, 2025'),
  RecentInspectedTree(treeNumber: 4, stage: 'Growing', predictedHarvest: '18 Mangoes', harvestDate: 'Oct 25, 2025'),
  RecentInspectedTree(treeNumber: 5, stage: 'Flowering', predictedHarvest: '22 Mangoes', harvestDate: 'Oct 30, 2025'),
];

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MangoTrackAppBar(notificationCount: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuickStatsSection(
              onSeeMore: () {
                // TODO: Navigate to detailed stats page
                print('Navigating to detailed stats page');
              },
            ),
            RecentInspectedTreesSection(
              trees: recentTrees,
              onTreeTap: (tree) {
                // TODO: Navigate to individual tree details
                print('Navigating to Tree #${tree.treeNumber} details');
              },
              onViewAllTrees: () {
                // TODO: Navigate to all trees view
                print('Navigating to all trees view');
              },
            ),
          ],
        ),
      ),
    );
  }
}
