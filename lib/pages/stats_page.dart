import 'package:flutter/material.dart';
import 'dart:math' as math;

// Data Models
class ClusterData {
  final int id;
  final String name;
  final List<TreeData> trees;

  ClusterData({required this.id, required this.name, required this.trees});
}

class TreeData {
  final int id;
  final TreeStatus status;
  final String variety;
  final DateTime lastWatered;
  final int soilMoisture;
  final double height;
  final int age;

  TreeData({
    required this.id,
    required this.status,
    required this.variety,
    required this.lastWatered,
    required this.soilMoisture,
    required this.height,
    required this.age,
  });
}

enum TreeStatus {
  healthy,
  unhealthy,
  readyToHarvest,
  needsWatering,
  needsPestControl,
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // Sample data - in real app, this would come from your backend
  final List<ClusterData> clusters = [
    ClusterData(
      id: 1,
      name: 'Cluster 1',
      trees: [
        TreeData(id: 1, status: TreeStatus.healthy, variety: 'Apple', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 75, height: 2.5, age: 3),
        TreeData(id: 2, status: TreeStatus.unhealthy, variety: 'Apple', lastWatered: DateTime.now().subtract(const Duration(days: 3)), soilMoisture: 35, height: 2.1, age: 3),
        TreeData(id: 3, status: TreeStatus.readyToHarvest, variety: 'Apple', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 80, height: 3.2, age: 5),
        TreeData(id: 4, status: TreeStatus.needsWatering, variety: 'Apple', lastWatered: DateTime.now().subtract(const Duration(days: 4)), soilMoisture: 25, height: 2.3, age: 2),
        TreeData(id: 5, status: TreeStatus.healthy, variety: 'Apple', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 70, height: 2.8, age: 4),
      ],
    ),
    ClusterData(
      id: 2,
      name: 'Cluster 2',
      trees: [
        TreeData(id: 6, status: TreeStatus.healthy, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 65, height: 3.0, age: 4),
        TreeData(id: 7, status: TreeStatus.readyToHarvest, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 85, height: 3.5, age: 6),
        TreeData(id: 8, status: TreeStatus.needsPestControl, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 60, height: 2.9, age: 3),
        TreeData(id: 9, status: TreeStatus.healthy, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 72, height: 3.1, age: 5),
      ],
    ),
    ClusterData(
      id: 3,
      name: 'Cluster 3',
      trees: [
        TreeData(id: 10, status: TreeStatus.unhealthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 5)), soilMoisture: 30, height: 1.8, age: 2),
        TreeData(id: 11, status: TreeStatus.healthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 78, height: 2.7, age: 3),
        TreeData(id: 12, status: TreeStatus.readyToHarvest, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 82, height: 4.1, age: 7),
        TreeData(id: 13, status: TreeStatus.needsWatering, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 3)), soilMoisture: 28, height: 2.2, age: 2),
        TreeData(id: 14, status: TreeStatus.needsPestControl, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 68, height: 3.3, age: 4),
        TreeData(id: 15, status: TreeStatus.healthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 71, height: 2.9, age: 3),
      ],
    ),
  ];

  late Map<TreeStatus, int> overallStats;
  late Map<TreeStatus, Color> statusColors;

  @override
  void initState() {
    super.initState();
    _calculateOverallStats();
    _initializeStatusColors();
  }

  void _calculateOverallStats() {
    overallStats = {};
    for (var cluster in clusters) {
      for (var tree in cluster.trees) {
        overallStats[tree.status] = (overallStats[tree.status] ?? 0) + 1;
      }
    }
  }

  void _initializeStatusColors() {
    statusColors = {
      TreeStatus.healthy: Colors.green,
      TreeStatus.unhealthy: Colors.red,
      TreeStatus.readyToHarvest: Colors.orange,
      TreeStatus.needsWatering: Colors.blue,
      TreeStatus.needsPestControl: Colors.purple,
    };
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

          // Cluster Summary
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
                    'Cluster Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...clusters.map((cluster) => _buildClusterSummary(cluster)),
                ],
              ),
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
                    'Detailed Breakdown',
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
        final percent = (count / totalTrees);

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
                      status.toString().split('.').last, // e.g., "healthy"
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

              // Percentage text
              Text('${(percent * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClusterSummary(ClusterData cluster) {
    final clusterStats = <TreeStatus, int>{};
    for (var tree in cluster.trees) {
      clusterStats[tree.status] = (clusterStats[tree.status] ?? 0) + 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
              Text(
                '${cluster.trees.length} trees',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: clusterStats.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColors[entry.key]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColors[entry.key]!.withOpacity(0.3)),
                ),
                child: Text(
                  '${_getStatusDisplayName(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    color: statusColors[entry.key]!.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(ClusterData cluster) {
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
          ...cluster.trees.where((tree) => tree.status != TreeStatus.healthy).map((tree) {
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
                    child: Text(
                      'Tree No. ${tree.id} is ${_getStatusDisplayName(tree.status).toLowerCase()}',
                      style: const TextStyle(fontSize: 14),
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
        builder: (context) => ClusterDetailsPage(cluster: cluster, statusColors: statusColors),
      ),
    );
  }

  void _navigateToTreeDetails(TreeData tree, ClusterData cluster) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeDetailsPage(tree: tree, cluster: cluster, statusColors: statusColors),
      ),
    );
  }

  String _getStatusDisplayName(TreeStatus status) {
    switch (status) {
      case TreeStatus.healthy:
        return 'Healthy';
      case TreeStatus.unhealthy:
        return 'Unhealthy';
      case TreeStatus.readyToHarvest:
        return 'Ready to Harvest';
      case TreeStatus.needsWatering:
        return 'Needs Watering';
      case TreeStatus.needsPestControl:
        return 'Needs Pest Control';
    }
  }
}

// Cluster Details Page
class ClusterDetailsPage extends StatelessWidget {
  final ClusterData cluster;
  final Map<TreeStatus, Color> statusColors;

  const ClusterDetailsPage({
    super.key,
    required this.cluster,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cluster.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cluster.trees.length,
        itemBuilder: (context, index) {
          final tree = cluster.trees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColors[tree.status]!,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text('Tree No. ${tree.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${tree.variety} • ${_getStatusDisplayName(tree.status)}'),
                  Text('Soil Moisture: ${tree.soilMoisture}%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
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
              },
            ),
          );
        },
      ),
    );
  }

  String _getStatusDisplayName(TreeStatus status) {
    switch (status) {
      case TreeStatus.healthy:
        return 'Healthy';
      case TreeStatus.unhealthy:
        return 'Unhealthy';
      case TreeStatus.readyToHarvest:
        return 'Ready to Harvest';
      case TreeStatus.needsWatering:
        return 'Needs Watering';
      case TreeStatus.needsPestControl:
        return 'Needs Pest Control';
    }
  }
}

// Individual Tree Details Page
class TreeDetailsPage extends StatelessWidget {
  final TreeData tree;
  final ClusterData cluster;
  final Map<TreeStatus, Color> statusColors;

  const TreeDetailsPage({
    super.key,
    required this.tree,
    required this.cluster,
    required this.statusColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tree No. ${tree.id}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColors[tree.status]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColors[tree.status]!.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: statusColors[tree.status]!,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.park, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusDisplayName(tree.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColors[tree.status]!,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Basic Information
            _buildInfoSection('Basic Information', [
              _buildInfoRow('Tree ID', 'Tree No. ${tree.id}'),
              _buildInfoRow('Variety', tree.variety),
              _buildInfoRow('Cluster', cluster.name),
              _buildInfoRow('Age', '${tree.age} years'),
              _buildInfoRow('Height', '${tree.height}m'),
            ]),

            const SizedBox(height: 20),

            // Environmental Data
            _buildInfoSection('Environmental Data', [
              _buildInfoRow('Soil Moisture', '${tree.soilMoisture}%'),
              _buildInfoRow('Last Watered', _formatDateTime(tree.lastWatered)),
              _buildProgressRow('Soil Moisture Level', tree.soilMoisture, 100, Colors.blue),
            ]),

            const SizedBox(height: 20),

            // Health Metrics
            _buildInfoSection('Health Metrics', [
              _buildHealthIndicator('Overall Health', tree.status == TreeStatus.healthy ? 85 : tree.status == TreeStatus.unhealthy ? 25 : 65),
              _buildHealthIndicator('Growth Rate', _calculateGrowthRate(tree)),
              _buildHealthIndicator('Nutrition Level', tree.soilMoisture > 60 ? 80 : 45),
            ]),

            const SizedBox(height: 20),

            // Action Recommendations
            _buildRecommendations(tree),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int current, int max, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              Text('$current/$max', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: current / max,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String label, int percentage) {
    Color color = percentage > 70 ? Colors.green : percentage > 40 ? Colors.orange : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(TreeData tree) {
    List<String> recommendations = [];

    switch (tree.status) {
      case TreeStatus.needsWatering:
        recommendations.add('Water immediately - soil moisture is critically low');
        recommendations.add('Check irrigation system');
        break;
      case TreeStatus.unhealthy:
        recommendations.add('Inspect for pests and diseases');
        recommendations.add('Consider soil testing');
        recommendations.add('Apply appropriate fertilizer');
        break;
      case TreeStatus.needsPestControl:
        recommendations.add('Apply pest control treatment');
        recommendations.add('Monitor for pest damage');
        break;
      case TreeStatus.readyToHarvest:
        recommendations.add('Schedule harvest within next week');
        recommendations.add('Prepare harvesting equipment');
        break;
      case TreeStatus.healthy:
        recommendations.add('Continue regular maintenance');
        recommendations.add('Monitor growth progress');
        break;
    }

    if (tree.soilMoisture < 40) {
      recommendations.add('Increase watering frequency');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(rec)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getStatusDisplayName(TreeStatus status) {
    switch (status) {
      case TreeStatus.healthy:
        return 'Healthy';
      case TreeStatus.unhealthy:
        return 'Unhealthy';
      case TreeStatus.readyToHarvest:
        return 'Ready to Harvest';
      case TreeStatus.needsWatering:
        return 'Needs Watering';
      case TreeStatus.needsPestControl:
        return 'Needs Pest Control';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }

  int _calculateGrowthRate(TreeData tree) {
    // Simple growth rate calculation based on height and age
    final expectedHeight = tree.age * 0.8; // Expected 0.8m per year
    final growthRate = ((tree.height / expectedHeight) * 100).clamp(0, 100).toInt();
    return growthRate;
  }
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final Map<TreeStatus, int> data;
  final Map<TreeStatus, Color> colors;

  PieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final total = data.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[entry.key]!
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Add white border between segments
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}