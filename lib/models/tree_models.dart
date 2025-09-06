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