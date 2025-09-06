import '../models/tree_models.dart';

class SampleData {
  static List<ClusterData> getClusters() {
    return [
      ClusterData(
        id: 1,
        name: 'Cluster A',
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
        name: 'Cluster B',
        trees: [
          TreeData(id: 6, status: TreeStatus.healthy, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 65, height: 3.0, age: 4),
          TreeData(id: 7, status: TreeStatus.readyToHarvest, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 85, height: 3.5, age: 6),
          TreeData(id: 8, status: TreeStatus.needsPestControl, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 60, height: 2.9, age: 3),
          TreeData(id: 9, status: TreeStatus.healthy, variety: 'Orange', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 72, height: 3.1, age: 5),
        ],
      ),
      ClusterData(
        id: 3,
        name: 'Cluster C',
        trees: [
          TreeData(id: 10, status: TreeStatus.unhealthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 5)), soilMoisture: 30, height: 1.8, age: 2),
          TreeData(id: 11, status: TreeStatus.healthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 78, height: 2.7, age: 3),
          TreeData(id: 12, status: TreeStatus.readyToHarvest, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 82, height: 4.1, age: 7),
          TreeData(id: 13, status: TreeStatus.needsWatering, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 3)), soilMoisture: 28, height: 2.2, age: 2),
          TreeData(id: 14, status: TreeStatus.needsPestControl, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 68, height: 3.3, age: 4),
          TreeData(id: 15, status: TreeStatus.healthy, variety: 'Mango', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 71, height: 2.9, age: 3),
        ],
      ),
      ClusterData(
        id: 4,
        name: 'Cluster D',
        trees: [
          TreeData(id: 16, status: TreeStatus.healthy, variety: 'Banana', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 77, height: 2.4, age: 2),
          TreeData(id: 17, status: TreeStatus.needsWatering, variety: 'Banana', lastWatered: DateTime.now().subtract(const Duration(days: 4)), soilMoisture: 22, height: 1.9, age: 2),
          TreeData(id: 18, status: TreeStatus.readyToHarvest, variety: 'Banana', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 85, height: 3.8, age: 4),
          TreeData(id: 19, status: TreeStatus.healthy, variety: 'Banana', lastWatered: DateTime.now().subtract(const Duration(days: 2)), soilMoisture: 69, height: 2.6, age: 3),
          TreeData(id: 20, status: TreeStatus.needsPestControl, variety: 'Banana', lastWatered: DateTime.now().subtract(const Duration(days: 1)), soilMoisture: 73, height: 2.8, age: 3),
        ],
      ),
    ];
  }
}