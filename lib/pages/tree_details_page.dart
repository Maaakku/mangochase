import 'package:flutter/material.dart';
import '../models/tree_models.dart';
import '../utils/tree_utils.dart';

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
                    TreeUtils.getStatusDisplayName(tree.status),
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
              _buildInfoRow('Last Watered', TreeUtils.formatDateTime(tree.lastWatered)),
              _buildProgressRow('Soil Moisture Level', tree.soilMoisture, 100, Colors.blue),
            ]),

            const SizedBox(height: 20),

            // Health Metrics
            _buildInfoSection('Health Metrics', [
              _buildHealthIndicator('Overall Health', tree.status == TreeStatus.healthy ? 85 : tree.status == TreeStatus.unhealthy ? 25 : 65),
              _buildHealthIndicator('Growth Rate', TreeUtils.calculateGrowthRate(tree)),
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
}