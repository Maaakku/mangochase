//recent_inspected_trees_section.dart
import 'package:flutter/material.dart';

class RecentInspectedTree {
  final int treeNumber;
  final String stage;
  final String predictedHarvest;
  final String harvestDate;

  RecentInspectedTree({
    required this.treeNumber,
    required this.stage,
    required this.predictedHarvest,
    required this.harvestDate,
  });
}

class RecentInspectedTreesSection extends StatelessWidget {
  final List<RecentInspectedTree> trees;
  final Function(RecentInspectedTree) onTreeTap;
  final VoidCallback onViewAllTrees;

  const RecentInspectedTreesSection({
    super.key,
    required this.trees,
    required this.onTreeTap,
    required this.onViewAllTrees,
  });

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'growing':
        return Colors.green;
      case 'flowering':
        return Colors.purple;
      case 'ripening':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

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
          // Header Row with Title and View All Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Inspected Trees',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: onViewAllTrees,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Enhanced Tree Cards
          ...trees.map((tree) => Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTreeTap(tree),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Left side: Tree info with stage badge
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tree #${tree.treeNumber}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Color-coded stage badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStageColor(tree.stage),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tree.stage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tree.predictedHarvest,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right side: Harvest date and arrow
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tree.harvestDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}