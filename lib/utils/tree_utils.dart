import 'package:flutter/material.dart';
import '../models/tree_models.dart';

class TreeUtils {
  static Map<TreeStatus, Color> getStatusColors() {
    return {
      TreeStatus.healthy: Colors.green,
      TreeStatus.unhealthy: Colors.red,
      TreeStatus.readyToHarvest: Colors.orange,
      TreeStatus.needsWatering: Colors.blue,
      TreeStatus.needsPestControl: Colors.purple,
    };
  }

  static String getStatusDisplayName(TreeStatus status) {
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

  static Map<TreeStatus, int> calculateOverallStats(List<ClusterData> clusters) {
    Map<TreeStatus, int> overallStats = {};
    for (var cluster in clusters) {
      for (var tree in cluster.trees) {
        overallStats[tree.status] = (overallStats[tree.status] ?? 0) + 1;
      }
    }
    return overallStats;
  }

  static Map<TreeStatus, int> calculateClusterStats(List<TreeData> trees) {
    Map<TreeStatus, int> clusterStats = {};
    for (var tree in trees) {
      clusterStats[tree.status] = (clusterStats[tree.status] ?? 0) + 1;
    }
    return clusterStats;
  }

  static String formatDateTime(DateTime dateTime) {
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

  static int calculateGrowthRate(TreeData tree) {
    // Simple growth rate calculation based on height and age
    final expectedHeight = tree.age * 0.8; // Expected 0.8m per year
    final growthRate = ((tree.height / expectedHeight) * 100).clamp(0, 100).toInt();
    return growthRate;
  }
}