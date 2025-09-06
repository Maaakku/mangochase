import 'package:flutter/material.dart';
import '../models/tree_models.dart';
import '../data/tree_models_data.dart';
import '../utils/tree_utils.dart';
import '../widgets/pie_chart_painter.dart';
import '../widgets/cluster_grid_widget.dart';
import 'cluster_details_page.dart';
import 'tree_details_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late List<ClusterData> clusters;
  late Map<TreeStatus, int> overallStats;
  late Map<TreeStatus, Color> statusColors;

  @override
  void initState() {
    super.initState();
    clusters = SampleData.getClusters();
    statusColors = TreeUtils.getStatusColors();
    _calculateOverallStats();
  }

  void _calculateOverallStats() {
    overallStats = TreeUtils.calculateOverallStats(clusters);
  }

  @override
  Widget build(BuildContext context) {
    final totalTrees = overallStats.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Statistics",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _calculateOverallStats();
                    });
                  },
                ),
              ],
            ),
          ),

          // Pie Chart and Legend
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Plant Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Pie Chart
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: PieChartPainter(overallStats, statusColors),
                      child: const SizedBox(width: 200, height: 200),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Legend
                  _buildLegend(totalTrees),
                ],
              ),
            ),
          ),

          // Cluster Grid Summary
          SliverToBoxAdapter(
            child: ClusterGridWidget(
              clusters: clusters,
              statusColors: statusColors,
              onClusterTap: _navigateToClusterDetails,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Detailed Breakdown
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trees Requiring Attention',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...clusters.map((cluster) => _buildDetailedBreakdown(cluster)),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLegend(int totalTrees) {
    return Column(
      children: overallStats.entries.map((entry) {
        final status = entry.key;
        final count = entry.value;
        final percent = totalTrees > 0 ? (count / totalTrees) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: statusColors[status],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Label + progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TreeUtils.getStatusDisplayName(status),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent,
                      color: statusColors[status],
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Count and percentage text
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(percent * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedBreakdown(ClusterData cluster) {
    // Only show trees that need attention (non-healthy status)
    final problematicTrees = cluster.trees.where((tree) => tree.status != TreeStatus.healthy).toList();
    
    if (problematicTrees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cluster.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () => _navigateToClusterDetails(cluster),
                child: const Text('View All Trees'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...problematicTrees.map((tree) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColors[tree.status]!.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColors[tree.status]!.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColors[tree.status]!,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tree No. ${tree.id} - ${tree.variety}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          TreeUtils.getStatusDisplayName(tree.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColors[tree.status]!,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () => _navigateToTreeDetails(tree, cluster),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _navigateToClusterDetails(ClusterData cluster) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClusterDetailsPage(
          cluster: cluster,
          statusColors: statusColors,
        ),
      ),
    );
  }

  void _navigateToTreeDetails(TreeData tree, ClusterData cluster) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeDetailsPage(
          tree: tree,
          cluster: cluster,
          statusColors: statusColors,
        ),
      ),
    );
  }
}