import 'package:flutter/material.dart';
import '../models/tree_models.dart';
import '../utils/tree_utils.dart';

class ClusterGridWidget extends StatelessWidget {
  final List<ClusterData> clusters;
  final Map<TreeStatus, Color> statusColors;
  final Function(ClusterData) onClusterTap;

  const ClusterGridWidget({
    super.key,
    required this.clusters,
    required this.statusColors,
    required this.onClusterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cluster Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${clusters.length} Clusters',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: clusters.length,
            itemBuilder: (context, index) {
              return _buildClusterCard(clusters[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClusterCard(ClusterData cluster) {
    final clusterStats = TreeUtils.calculateClusterStats(cluster.trees);
    final healthyCount = clusterStats[TreeStatus.healthy] ?? 0;
    final totalTrees = cluster.trees.length;
    final healthPercentage = totalTrees > 0 ? (healthyCount / totalTrees * 100).round() : 0;
    
    // Get the most critical status (non-healthy with highest count)
    TreeStatus? criticalStatus;
    int maxCriticalCount = 0;
    
    clusterStats.forEach((status, count) {
      if (status != TreeStatus.healthy && count > maxCriticalCount) {
        criticalStatus = status;
        maxCriticalCount = count;
      }
    });

    return GestureDetector(
      onTap: () => onClusterTap(cluster),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with cluster name and tree count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cluster.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$totalTrees',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Health percentage indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: healthPercentage > 70 ? Colors.green : 
                           healthPercentage > 40 ? Colors.orange : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$healthPercentage% Healthy',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Critical issue indicator (if any)
            if (criticalStatus != null && maxCriticalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColors[criticalStatus]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColors[criticalStatus]!.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(criticalStatus!),
                      size: 12,
                      color: statusColors[criticalStatus]!,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$maxCriticalCount ${TreeUtils.getStatusDisplayName(criticalStatus!)}',
                        style: TextStyle(
                          color: statusColors[criticalStatus]!,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // View details button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(TreeStatus status) {
    switch (status) {
      case TreeStatus.needsWatering:
        return Icons.water_drop;
      case TreeStatus.unhealthy:
        return Icons.warning;
      case TreeStatus.needsPestControl:
        return Icons.bug_report;
      case TreeStatus.readyToHarvest:
        return Icons.agriculture;
      default:
        return Icons.check_circle;
    }
  }
}