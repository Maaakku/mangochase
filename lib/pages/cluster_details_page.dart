import 'package:flutter/material.dart';
import '../models/tree_models.dart';
import '../utils/tree_utils.dart';
import 'tree_details_page.dart';

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
                  Text('${tree.variety} • ${TreeUtils.getStatusDisplayName(tree.status)}'),
                  Text(
                    'Soil Moisture: ${tree.soilMoisture}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
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
}